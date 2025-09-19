class Appointment < ApplicationRecord
  include Filterable
  belongs_to :time_slot
  belongs_to :user
  belongs_to :consultation_room, optional: true
  has_many :appointment_interns, dependent: :destroy
  has_many :interns, through: :appointment_interns, source: :intern

  has_many :status_histories,
           class_name:  "AppointmentStatusHistory",
           dependent:   :destroy,
           inverse_of:  :appointment

  scope :active, -> { where(status: [:pending, :admin_confirmed, :patient_confirmed]) }

  enum :status, {
    pending: 0,               # Pendente
    admin_confirmed: 1,       # Confirmado pelo administrador
    cancelled_by_admin: 2,    # Cancelado pelo administrador
    rejected: 3,              # Rejeitado
    completed: 4,             # Concluído
    patient_confirmed: 5,     # Confirmado pelo paciente
    patient_cancelled: 6      # Cancelado pelo paciente
  }

  validates :date, :start_time, :end_time, presence: true
  validate :end_time_after_start_time

  before_update :log_status_change, if: :status_changed?
  after_create_commit :notify_on_create
  after_update_commit :notify_on_status_change, if: :saved_change_to_status?

  validate :interns_count_within_limits

  private

  def end_time_after_start_time
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def log_status_change
    status_histories.create!(
      from_status: status_was,
      to_status:   status,
      changed_by:  Current.user,      # use uma Current ou passe via service
      changed_at:  Time.current
    )
  end

  def interns_count_within_limits
    return unless interns.loaded? || interns.any?

    if interns.size < 1 || interns.size > 3
      errors.add(:interns, "must have between 1 and 3 interns")
    end
  end

  def notify_on_create
    # Ao criar, fica em pending (agendado à espera de confirmação do admin)
    begin
      Notification.create!(
        user: user,
        title: 'Sua consulta foi agendada',
        body: "Sua solicitação de consulta para #{I18n.l(date)} às #{I18n.l(start_time, format: :hour_min)} foi registrada e aguarda confirmação do gestor.",
        appointment: self,
        url: "consultas/#{id}",
        data: { event: 'appointment_created', status: status }
      )
    rescue => e
      Rails.logger.error("Erro ao criar notificação (create): #{e.message}")
    end
  end

  def notify_on_status_change
    from, to = status_before_last_save, status
    # Cria mensagens diferentes conforme transição
    case to.to_sym
    when :admin_confirmed
      Notification.create!(
        user: user,
        title: 'Consulta confirmada pelo administrador',
        body: "Sua consulta em #{I18n.l(date)} às #{I18n.l(start_time, format: :hour_min)} foi confirmada pelo administrador e está aguardando a sua confirmação final.",
        appointment: self,
        url: "consultas/#{id}",
        data: { event: 'admin_confirmed', from: from, to: to }
      )
    when :patient_confirmed
      # Notifica os gestores da especialidade
      specialty = time_slot.specialty
      return unless specialty
      specialty_managers = User.joins(:profile).where(profiles: { name: 'Gestor' }, specialty_id: specialty.id) 
      specialty_managers.each do |manager|
        Notification.create!(
          user: manager,
          title: 'Consulta confirmada pelo paciente',
          body: "O paciente #{user.name} confirmou a consulta em #{I18n.l(date)} às #{I18n.l(start_time, format: :hour_min)}.",
          appointment: self,
          url: "consultas/#{id}",
          data: { event: 'patient_confirmed', from: from, to: to }
        )
      end
    when :cancelled_by_admin
      Notification.create!(
        user: user,
        title: 'Consulta cancelada',
        body: "Sua consulta em #{I18n.l(date)} às #{I18n.l(start_time, format: :hour_min)} foi cancelada por um gestor.",
        appointment: self,
        url: "consultas/#{id}",
        data: { event: 'cancelled', from: from, to: to }
      )
    when :patient_cancelled
      # Notification.create!(
      #   user: user,
      #   title: 'Consulta cancelada',
      #   body: "Você cancelou sua consulta em #{I18n.l(date)} às #{
      #     I18n.l(start_time, format: :hour_min)}.",
      #   appointment: self,
      #   url: "consultas/#{id}",
      #   data: { event: 'patient_cancelled', from: from, to: to }
      # )
    when :rejected
      Notification.create!(
        user: user,
        title: 'Consulta rejeitada',
        body: "Sua solicitação de consulta para #{I18n.l(date)} às #{I18n.l(start_time, format: :hour_min)} foi rejeitada.",
        appointment: self,
        url: "consultas/#{id}",
        data: { event: 'rejected', from: from, to: to }
      )
    end
  rescue => e
    Rails.logger.error("Erro ao criar notificação (status_change): #{e.message}")
  end
end

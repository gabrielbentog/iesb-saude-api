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
end

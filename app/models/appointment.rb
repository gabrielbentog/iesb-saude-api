class Appointment < ApplicationRecord
  include Filterable
  belongs_to :time_slot
  belongs_to :user
  belongs_to :consultation_room, optional: true
  belongs_to :intern, class_name: 'User', optional: true

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

  private

  def end_time_after_start_time
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end

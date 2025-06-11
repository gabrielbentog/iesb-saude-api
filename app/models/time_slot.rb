class TimeSlot < ApplicationRecord
  belongs_to :college_location
  belongs_to :specialty
  belongs_to :intern, class_name: 'User', optional: true

  has_one :recurrence_rule, dependent: :destroy

  has_many :exceptions, class_name: "TimeSlotException", dependent: :delete_all
  has_many :appointments, dependent: :nullify

  validates :start_time, :end_time, presence: true

  accepts_nested_attributes_for :recurrence_rule, allow_destroy: true

  before_save :set_turn
  before_destroy :fix_appointments, prepend: true
  validate :can_destroy?, on: :destroy
  private

  def set_turn
    self.turn = case start_time.hour
    when 0..11 then 'Manhã'
    when 12..17 then 'Tarde'
    else 'Noite'
    end
  end

  def can_destroy?
    if appointments.exists? && recurrence_rule.nil?
      errors.add(:base, 'Não é possível excluir um horário com agendamentos.')
    end
  end

  def fix_appointments
    if appointments.exists? && recurrence_rule.present?
      appointments.each do |appointment|
        new_time_slot = TimeSlot.create!(
          college_location: college_location,
          specialty: specialty,
          start_time: appointment.start_time,
          end_time: appointment.end_time,
          date: appointment.date,
          turn: turn,
        )

        appointment.update!(time_slot: new_time_slot)
      end
    end
  end
end

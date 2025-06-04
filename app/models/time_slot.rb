class TimeSlot < ApplicationRecord
  belongs_to :college_location
  belongs_to :specialty
  belongs_to :intern, class_name: 'User', optional: true

  has_one :recurrence_rule, dependent: :destroy

  has_many :exceptions, class_name: "TimeSlotException", dependent: :delete_all
  has_one :appointment, dependent: :nullify

  validates :start_time, :end_time, presence: true

  accepts_nested_attributes_for :recurrence_rule, allow_destroy: true

  before_save :set_turn

  private

  def set_turn
    self.turn = case start_time.hour
    when 0..11 then 'Manhã'
    when 12..17 then 'Tarde'
    else 'Noite'
    end
  end
end

class TimeSlot < ApplicationRecord
  belongs_to :college_location
  belongs_to :specialty
  belongs_to :intern, class_name: 'User', optional: true

  has_one :recurrence_rule, dependent: :destroy

  validates :day_of_week, :start_time, :end_time, presence: true

  accepts_nested_attributes_for :recurrence_rule, allow_destroy: true
end

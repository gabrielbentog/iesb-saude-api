class RecurrenceRule < ApplicationRecord
  belongs_to :time_slot

  validates :start_date, :end_date, :frequency_type, presence: true
end

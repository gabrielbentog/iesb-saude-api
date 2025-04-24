class Appointment < ApplicationRecord
  belongs_to :time_slot
  belongs_to :user

  enum :status, { pending: 0, confirmed: 1, cancelled: 2 }, prefix: true

  validates :date_of_service, :start_time, :end_time, presence: true
end

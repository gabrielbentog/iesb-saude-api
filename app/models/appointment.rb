class Appointment < ApplicationRecord
  include Filterable
  belongs_to :time_slot
  belongs_to :user
  belongs_to :consultation_room, optional: true
  belongs_to :intern, class_name: 'User', optional: true

  enum :status, { pending: 0, confirmed: 1, cancelled: 2, scheduled: 3, completed: 4 }, prefix: true

  validates :date, :start_time, :end_time, presence: true

  scope :scheduled, -> { where(status: :scheduled) }
  scope :completed, -> { where(status: :confirmed) }
  scope :cancelled, -> { where(status: :cancelled) }
  scope :pending, -> { where(status: :pending) }

  # Custom validation to ensure end_time is after start_time
  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end

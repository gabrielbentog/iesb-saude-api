class Appointment < ApplicationRecord
  include Filterable
  belongs_to :time_slot
  belongs_to :user

  enum :status, { pending: 0, confirmed: 1, cancelled: 2 }, prefix: true

  validates :date, :start_time, :end_time, presence: true

  scope :scheduled, -> { where(status: :pending) }
  scope :completed, -> { where(status: :confirmed) }
  scope :cancelled, -> { where(status: :cancelled) }

  # Custom validation to ensure end_time is after start_time
  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end

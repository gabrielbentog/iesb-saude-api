class TimeSlotSerializer < BaseSerializer
  attributes :id, :turn, :start_time, :end_time, :week_day, :is_recurring
  has_one :college_location
end

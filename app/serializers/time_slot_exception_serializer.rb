class TimeSlotExceptionSerializer < BaseSerializer
  attributes :id, :date, :start_time, :end_time, :reason
  has_one :time_slot
end

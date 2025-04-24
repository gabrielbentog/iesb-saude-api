class TimeSlotExceptionSerializer < ActiveModel::Serializer
  attributes :id, :date, :start_time, :end_time, :reason
  has_one :time_slot
end

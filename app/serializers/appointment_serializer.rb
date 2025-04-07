class AppointmentSerializer < ActiveModel::Serializer
  attributes :id, :date, :start_time, :end_time, :status, :notes
  has_one :time_slot
  has_one :user
end

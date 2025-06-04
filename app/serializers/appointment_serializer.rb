class AppointmentSerializer < BaseSerializer
  attributes :id, :date, :start_time, :end_time, :status, :notes
  has_one :user

  attribute :time_slot do |serializer|
    time_slot = serializer.object.time_slot

    if time_slot
      {
        id: time_slot.id,
        college_location_name: time_slot.college_location&.name,
        specialty_name: time_slot.specialty&.name,
      }
    end
  end
end

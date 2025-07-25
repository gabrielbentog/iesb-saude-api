class AppointmentSerializer < BaseSerializer
  attributes :id, :date, :start_time, :end_time, :status, :notes, :user

  attribute :user do |serializer|
    user = serializer.object.user
    if user
      {
        id: user.id,
        name: user.name,
        email: user.email,
        cpf: "",
        avatarUrl: "",
        phone: "",
      }
    end
  end

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

  attribute :consultation_room do |serializer|
    consultation_room = serializer.object.consultation_room

    if consultation_room
      {
        id: consultation_room.id,
        name: consultation_room.name,
        college_location_name: consultation_room.college_location&.name,
        specialty_name: consultation_room.specialty&.name,
      }
    end
  end

  attribute :intern do |serializer|
    intern = serializer.object.intern

    if intern
      {
        id: intern.id,
        name: intern.name,
      }
    end
  end
end

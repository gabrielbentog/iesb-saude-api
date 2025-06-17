class AddConsultationRoomToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_reference :appointments, :consultation_room, foreign_key: true, type: :uuid
  end
end

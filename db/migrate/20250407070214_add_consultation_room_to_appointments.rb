class AddConsultationRoomToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_reference :appointments, :consultation_room, foreign_key: true
  end
end

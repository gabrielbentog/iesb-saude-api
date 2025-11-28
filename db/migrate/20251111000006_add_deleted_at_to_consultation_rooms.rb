class AddDeletedAtToConsultationRooms < ActiveRecord::Migration[8.0]
  def change
    add_column :consultation_rooms, :deleted_at, :datetime
    add_index :consultation_rooms, :deleted_at
  end
end

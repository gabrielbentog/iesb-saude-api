class AddDeletedAtToTimeSlots < ActiveRecord::Migration[8.0]
  def change
    add_column :time_slots, :deleted_at, :datetime
    add_index :time_slots, :deleted_at
  end
end

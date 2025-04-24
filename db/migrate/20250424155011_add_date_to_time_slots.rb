class AddDateToTimeSlots < ActiveRecord::Migration[8.0]
  def change
    add_column :time_slots, :date, :date
  end
end

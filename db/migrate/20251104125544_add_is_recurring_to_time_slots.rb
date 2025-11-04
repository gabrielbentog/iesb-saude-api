class AddIsRecurringToTimeSlots < ActiveRecord::Migration[8.0]
  def change
    add_column :time_slots, :is_recurring, :boolean, default: false, null: false
  end
end

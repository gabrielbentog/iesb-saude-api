class AddDeletedAtToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :deleted_at, :datetime
    add_index :appointments, :deleted_at
  end
end

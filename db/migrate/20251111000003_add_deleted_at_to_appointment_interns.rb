class AddDeletedAtToAppointmentInterns < ActiveRecord::Migration[8.0]
  def change
    add_column :appointment_interns, :deleted_at, :datetime
    add_index :appointment_interns, :deleted_at
  end
end

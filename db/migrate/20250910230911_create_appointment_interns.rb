class CreateAppointmentInterns < ActiveRecord::Migration[8.0]
  def change
    create_table :appointment_interns, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :appointment_id, null: false
      t.uuid :intern_id, null: false

      t.timestamps
    end

    add_index :appointment_interns, [:appointment_id, :intern_id], unique: true
    add_index :appointment_interns, :intern_id

    remove_column :appointments, :intern_id, :uuid
    add_foreign_key :appointment_interns, :appointments
    add_foreign_key :appointment_interns, :users, column: :intern_id
  end
end

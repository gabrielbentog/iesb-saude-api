class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments, id: :uuid do |t|
      t.references :time_slot, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.date :date
      t.time :start_time
      t.time :end_time
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end

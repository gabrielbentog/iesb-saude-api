class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      t.references :time_slot, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.time :start_time
      t.time :end_time
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end

class CreateTimeSlotExceptions < ActiveRecord::Migration[8.0]
  def change
    create_table :time_slot_exceptions do |t|
      t.references :time_slot, null: false, foreign_key: true
      t.date :date
      t.time :start_time
      t.time :end_time
      t.string :reason

      t.timestamps
    end
  end
end

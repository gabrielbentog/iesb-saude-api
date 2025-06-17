class CreateTimeSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :time_slots, id: :uuid do |t|
      t.references :college_location, null: false, foreign_key: true, type: :uuid
      t.references :specialty, null: false, foreign_key: true, type: :uuid
      t.references :intern, foreign_key: { to_table: :users }, type: :uuid
      t.integer :turn
      t.time :start_time
      t.time :end_time
      t.integer :week_day

      t.timestamps
    end
  end
end

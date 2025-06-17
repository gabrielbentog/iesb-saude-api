class CreateRecurrenceRules < ActiveRecord::Migration[8.0]
  def change
    create_table :recurrence_rules, id: :uuid do |t|
      t.references :time_slot, null: false, foreign_key: true, type: :uuid
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :frequency_type, null: false
      t.integer :frequency_interval
      t.integer :max_occurrences

      t.timestamps
    end
  end
end

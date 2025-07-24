class CreateAppointmentStatusHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :appointment_status_histories, id: :uuid do |t|
      t.references :appointment, null: false, foreign_key: true, type: :uuid
      t.integer :from_status
      t.integer :to_status
      t.references :changed_by, polymorphic: true, null: false, type: :uuid
      t.datetime   :changed_at,   null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end
  end
end

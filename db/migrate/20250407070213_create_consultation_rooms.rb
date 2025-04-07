class CreateConsultationRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :consultation_rooms do |t|
      t.references :college_location, null: false, foreign_key: true
      t.references :specialty, null: false, foreign_key: true
      t.string :name
      t.boolean :active

      t.timestamps
    end
  end
end

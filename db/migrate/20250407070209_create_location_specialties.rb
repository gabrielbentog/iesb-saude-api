class CreateLocationSpecialties < ActiveRecord::Migration[8.0]
  def change
    create_table :location_specialties do |t|
      t.references :college_location, null: false, foreign_key: true
      t.references :specialty, null: false, foreign_key: true

      t.timestamps
    end

    add_index :location_specialties, 
      [:college_location_id, :specialty_id], 
      unique: true, 
      name: "index_location_specialties_on_location_and_specialty"
  end
end

class CreateCollegeLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :college_locations do |t|
      t.string :name
      t.string :location

      t.timestamps
    end
  end
end

class AddDeletedAtToCollegeLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :college_locations, :deleted_at, :datetime
    add_index :college_locations, :deleted_at
  end
end

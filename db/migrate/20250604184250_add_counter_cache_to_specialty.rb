class AddCounterCacheToSpecialty < ActiveRecord::Migration[8.0]
  def change
    add_column :specialties, :users_count, :integer
  end

  def up
    Specialty.reset_column_information
    Specialty.find_each do |specialty|
      Specialty.reset_counters(specialty.id, :users)
    end
  end
end

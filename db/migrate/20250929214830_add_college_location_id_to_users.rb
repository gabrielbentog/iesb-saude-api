class AddCollegeLocationIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :college_location, foreign_key: true, type: :uuid
  end
end

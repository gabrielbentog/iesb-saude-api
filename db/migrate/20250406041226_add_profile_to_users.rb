class AddProfileToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :profile, null: false, foreign_key: true
  end
end

class AddRegistrationToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :registration, :integer
  end
end

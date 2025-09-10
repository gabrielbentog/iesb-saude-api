class AddRegistrationCodeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :registration_code, :string
    add_index :users, :registration_code
  end
end

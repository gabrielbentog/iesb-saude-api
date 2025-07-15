class AddResetCodeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :reset_password_code_digest, :string
    add_column :users, :reset_password_code_sent_at, :datetime
  end
end

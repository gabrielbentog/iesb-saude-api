class AddCpfAndPhoneToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :cpf, :string
    add_column :users, :phone, :string
  end
end

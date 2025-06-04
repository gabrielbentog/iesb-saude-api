class AddSpecialtyReferenceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :specialty, foreign_key: true
  end
end

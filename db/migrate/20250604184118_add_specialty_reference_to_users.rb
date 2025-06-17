class AddSpecialtyReferenceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :specialty, foreign_key: true, type: :uuid
  end
end

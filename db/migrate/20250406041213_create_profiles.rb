class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles, id: :uuid do |t|
      t.string :name, null: false
      t.integer :users_count, default: 0, null: false

      t.timestamps
    end
  end
end

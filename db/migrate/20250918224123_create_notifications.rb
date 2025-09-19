class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :appointment, foreign_key: true, type: :uuid
      t.string :title, null: false
      t.text :body, null: false
      t.boolean :read, default: false, null: false
      t.jsonb :data, default: {}
      t.string :url

      t.timestamps
    end

    add_index :notifications, :read
  end
end

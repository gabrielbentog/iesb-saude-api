class AddThemePreferenceToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :theme_preference, :integer, default: 0, null: false
  end
end

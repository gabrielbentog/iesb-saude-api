class CreateSpecialties < ActiveRecord::Migration[8.0]
  def change
    create_table :specialties, id: :uuid do |t|
      t.string :name
      t.text :description
      t.boolean :active

      t.timestamps
    end
  end
end

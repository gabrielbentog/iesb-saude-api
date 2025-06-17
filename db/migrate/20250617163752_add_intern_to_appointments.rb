class AddInternToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_reference :appointments, :intern, foreign_key: { to_table: :users }, type: :uuid
  end
end

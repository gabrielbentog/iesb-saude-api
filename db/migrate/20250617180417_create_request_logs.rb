class CreateRequestLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :request_logs, id: :uuid do |t|
      t.string :method
      t.string :path
      t.string :controller
      t.string :action
      t.json :params
      t.string :ip
      t.uuid :user_id
      t.string :model_touchedt

      t.timestamps
    end
  end
end
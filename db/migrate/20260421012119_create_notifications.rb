class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications, primary_key: :notification_id, id: :uuid, default: "gen_random_uuid()" do |t|
      t.integer :user_id, null: false
      t.integer :send_to_user_id, null: false
      t.text :content, null: false
      t.string :url, null: false
      t.string :action, null: false
      t.string :language, null: false
      t.string :status, null: false
      t.boolean :send_email_status, default: false
      t.jsonb :info, default: {}
      t.timestamps
    end

    add_foreign_key :notifications, :users, column: :user_id, primary_key: :user_id
    add_foreign_key :notifications, :users, column: :send_to_user_id, primary_key: :user_id
  end
end

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, primary_key: :user_id, id: :serial do |t|
      t.string :name, limit: 32
      t.string :email, limit: 50, null: false
      t.string :password, null: false
      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end

class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts, primary_key: :post_id, id: :string do |t|
      t.string :url, null: false
      t.string :embedUrl
      t.string :title, null: false
      t.text :content, null: false
      t.integer :user_id, null: false
      t.string :like_user_ids, array: true, default: []
      t.timestamps
    end

    add_foreign_key :posts, :users, column: :user_id, primary_key: :user_id
  end
end

class AddDislikeUserIdsToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :dislike_user_ids, :string, array: true, default: []
  end
end

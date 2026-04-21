class Post < ApplicationRecord
  self.table_name = "posts"
  self.primary_key = "post_id"
  
  belongs_to :user, foreign_key: :user_id, primary_key: :user_id
  validates :url, :title, :content, presence: true
end

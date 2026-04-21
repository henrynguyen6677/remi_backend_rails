class User < ApplicationRecord
  self.table_name = :users
  self.primary_key = :user_id

  has_secure_password

  has_many :posts, foreign_key: :user_id
  has_many :notifications, foreign_key: :user_id

  validates :email, presence: true, uniqueness: true
end

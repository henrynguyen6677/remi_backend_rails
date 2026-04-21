class Notification < ApplicationRecord
  self.table_name = 'notification'
  self.primary_key = 'notification_id'

  belongs_to :user, foreign_key: :user_id, primary_key: :user_id
  belongs_to :send_to_user, class_name: 'User', foreign_key: :send_to_user_id, primary_key: :user_id
end

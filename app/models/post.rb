class Post < ApplicationRecord
  self.table_name = "posts"
  self.primary_key = "post_id"
  
  belongs_to :user, foreign_key: :user_id, primary_key: :user_id
  validates :url, :title, :content, presence: true

  def toggle_vote(user, type)
    uid = user.user_id.to_s
    self.like_user_ids ||= []
    self.dislike_user_ids ||= []

    case type
    when "UP", "SELF_VOTE_UP"
      like_user_ids.include?(uid) ? self.like_user_ids -= [uid] : (self.like_user_ids |= [uid]; self.dislike_user_ids -= [uid])
    when "DOWN", "SELF_VOTE_DOWN"
      dislike_user_ids.include?(uid) ? self.dislike_user_ids -= [uid] : (self.dislike_user_ids |= [uid]; self.like_user_ids -= [uid])
    end

    save
  end
end

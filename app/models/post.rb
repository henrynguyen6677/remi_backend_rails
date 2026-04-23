class Post < ApplicationRecord
  self.table_name = "posts"
  self.primary_key = "post_id"
  
  belongs_to :user, foreign_key: :user_id, primary_key: :user_id
  validates :url, :title, :content, presence: true

  VOTE_UP = "UP".freeze
  VOTE_DOWN = "DOWN".freeze
  SELF_VOTE_UP = "SELF_VOTE_UP".freeze
  SELF_VOTE_DOWN = "SELF_VOTE_DOWN".freeze

  def toggle_vote(user, type)
    uid = user.user_id.to_s
    self.like_user_ids ||= []
    self.dislike_user_ids ||= []

    case type
    when VOTE_UP, SELF_VOTE_UP
      if like_user_ids.include?(uid)
        self.like_user_ids -= [uid]
      else
        self.like_user_ids |= [uid]
        self.dislike_user_ids -= [uid]
      end
    when VOTE_DOWN, SELF_VOTE_DOWN
      if dislike_user_ids.include?(uid)
        self.dislike_user_ids -= [uid]
      else
        self.dislike_user_ids |= [uid]
        self.like_user_ids -= [uid]
      end
    end

    save
  end

  def vote_summary(user_id = nil)
    likes = like_user_ids || []
    dislikes = dislike_user_ids || []

    status = ""
    if user_id.present?
      uid_str = user_id.to_s
      status = VOTE_UP if likes.include?(uid_str)
      status = VOTE_DOWN if dislikes.include?(uid_str)
    end

    {
      up: likes.size,
      down: dislikes.size,
      self_vote_status: status
    }
  end
end

# frozen_string_literal: true

module Types
  class PostResponseType < Types::BaseObject
    field :post_id, String, null: false
    field :title, String, null: false
    field :content, String, null: false
    field :url, String, null: false
    field :embed_url, String, null: false, hash_key: :embedUrl
    field :user, Types::UserResponseType, null: false
    field :vote, Types::VoteOutputType, null: false
    field :like_user_ids, [String], null: false
    field :dis_like_user_ids, [String], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    def vote
      user_id = context[:current_user]&.user_id&.to_s
      like_ids = object.like_user_ids || []
      dislike_ids = object.dislike_user_ids || []
      self_vote_status = ""
      if user_id.present?
        self_vote_status = "UP" if like_ids.include?(user_id)
        self_vote_status = "DOWN" if dislike_ids.include?(user_id)
      end
      {
        up: like_ids.size,
        down: dislike_ids.size, 
        self_vote_status: self_vote_status
      }
    end

  end
end

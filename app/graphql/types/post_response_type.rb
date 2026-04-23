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
      object.vote_summary(context[:current_user]&.user_id)
    end

  end
end

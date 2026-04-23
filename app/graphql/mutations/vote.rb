# frozen_string_literal: true

module Mutations
  class Vote < Mutations::BaseMutation
    argument :create_vote_input, Types::CreateVoteInputType, required: true

    type Types::PostResponseType
    
    def resolve(create_vote_input:)
      user = context[:current_user]
      raise ApiErrors::Error, ApiErrors::UNAUTHORIZED unless user

      post = Post.find(create_vote_input.post_id)
      raise ApiErrors::Error, ApiErrors::POST_NOT_FOUND unless post

      post.toggle_vote(user, create_vote_input.vote)
      post
    end
  end
end

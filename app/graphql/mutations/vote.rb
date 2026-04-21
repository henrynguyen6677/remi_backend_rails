# frozen_string_literal: true

module Mutations
  class Vote < Mutations::BaseMutation
    argument :create_vote_input, Types::CreateVoteInputInputType, required: true

    type Types::PostResponseType
    
    def resolve(create_vote_input:)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user

      post = Post.find(create_vote_input.post_id)
      raise GraphQL::ExecutionError, "Post not found" unless post

      vote_type = create_vote_input.vote 
      user_id_str = user.user_id.to_s
      like_ids = post.like_user_ids || []
      dislike_ids = post.dislike_user_ids || []
      if vote_type == "UP"
        if like_ids.include?(user_id_str)
          like_ids.delete(user_id_str)
        else
          like_ids << user_id_str
          dislike_ids.delete(user_id_str)
        end
      elsif vote_type == "DOWN"
        if dislike_ids.include?(user_id_str)
          dislike_ids.delete(user_id_str)
        else
          dislike_ids << user_id_str  
          like_ids.delete(user_id_str)  
        end
      end

      post.update(
        like_user_ids: like_ids,
        dislike_user_ids: dislike_ids
      )
      post
    end
  end
end

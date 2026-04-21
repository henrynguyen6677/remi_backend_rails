# frozen_string_literal: true

module Queries
  class PostsQuery < GraphQL::Schema::Resolver
    argument :find_all_input, Types::FindAllInputInputType, required: false
    type [Types::PostResponseType], null: false

    def resolve(find_all_input: nil)
      take = find_all_input&.take&.to_i || 10
      take = 10 if take <= 0
      skip = find_all_input&.skip&.to_i || 0

      Post.includes(:user).order(created_at: :desc).offset(skip).limit(take)
    end
  end
end

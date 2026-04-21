# frozen_string_literal: true
module Queries
  class UsersGetProfile < GraphQL::Schema::Resolver
    type Types::UserResponseType, null: true
    
    def resolve 
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user

      user
    end
  end
end

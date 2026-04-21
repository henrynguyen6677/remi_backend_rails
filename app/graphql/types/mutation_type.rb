# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field "auth_register", mutation: Mutations::AuthRegister
    field "createPost", mutation: Mutations::CreatePost
    field "vote", mutation: Mutations::Vote              
  end
end

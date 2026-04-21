# frozen_string_literal: true

module Types
  class UserResponseType < Types::BaseObject
    field :user_id, Float, null: false
    field :email, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

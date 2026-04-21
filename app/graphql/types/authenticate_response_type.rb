# frozen_string_literal: true

module Types
  class AuthenticateResponseType < Types::BaseObject
    field :access_token, String, null: false
    field :email, String, null: false
    field :user_id, Float, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

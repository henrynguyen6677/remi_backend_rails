# frozen_string_literal: true

module Types
  class VoteOutputType < Types::BaseObject
    field :up, Float, null: false
    field :down, Float, null: false
    field :self_vote_status, String, null: false, method: :self_vote_status
  end
end

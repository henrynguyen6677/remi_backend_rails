# frozen_string_literal: true

module Types
  class CreateVoteInputType < Types::BaseInputObject
    argument :post_id, String, required: true
    argument :vote, String, required: true
  end
end

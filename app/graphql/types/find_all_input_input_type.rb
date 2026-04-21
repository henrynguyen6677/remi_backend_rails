# frozen_string_literal: true

module Types
  class FindAllInputInputType < Types::BaseInputObject
    argument :skip, Integer, required: false
    argument :take, Integer, required: false
    argument :user_id, Integer, required: false
  end
end

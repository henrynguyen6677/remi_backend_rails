# frozen_string_literal: true

module Types
  class RegisterInputType < Types::BaseInputObject
    argument :email, String, required: true
    argument :password, String, required: true
  end
end

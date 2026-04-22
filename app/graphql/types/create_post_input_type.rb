# frozen_string_literal: true

module Types
  class CreatePostInputType < Types::BaseInputObject
    argument :youtube_url, String, required: true
  end
end

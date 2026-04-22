# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::CreatePost do
  let(:user) { create(:user) }

  let(:valid_api_response) do
    {
      "items" => [
        {
          "snippet" => {
            "title" => "Rick Astley - Never Gonna Give You Up",
            "description" => "The official video for Rick Astley",
            "channelTitle" => "Rick Astley"
          }
        }
      ]
    }.to_json
  end

  def execute_query(variables: {}, context: {})
    query = <<~GQL
      mutation createPost($input: CreatePostInput!) {
        createPost(createPostInput: $input) {
          title
          content
          url
          embedUrl
        }
      }
    GQL
    BackendRailsSchema.execute(query, variables: variables, context: context)
  end

  describe "resolve" do
    it "returns Unauthorized when no user in context" do
      result = execute_query(
        variables: { input: { youtubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ" } },
        context: { current_user: nil }
      )
      errors = result["errors"]
      expect(errors).to be_present
      expect(errors.first["message"]).to eq("Unauthorized")
    end

    it "returns ERROR_INVALID_YOUTUBE_URL for invalid URL" do
      result = execute_query(
        variables: { input: { youtubeUrl: "https://not-youtube.com/blah" } },
        context: { current_user: user }
      )
      errors = result["errors"]
      expect(errors).to be_present
      expect(errors.first["message"]).to eq("ERROR_INVALID_YOUTUBE_URL")
    end

    it "returns ERROR_VIDEO_RESTRICTED when API fails" do
      stub_request(:get, /googleapis\.com\/youtube\/v3\/videos/)
        .to_return(status: 403, body: "Forbidden")

      result = execute_query(
        variables: { input: { youtubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ" } },
        context: { current_user: user }
      )
      errors = result["errors"]
      expect(errors).to be_present
      expect(errors.first["message"]).to eq("ERROR_VIDEO_RESTRICTED")
    end

    it "creates a post with description as content" do
      stub_request(:get, /googleapis\.com\/youtube\/v3\/videos/)
        .to_return(status: 200, body: valid_api_response, headers: { "Content-Type" => "application/json" })

      allow(ActionCable.server).to receive(:broadcast)

      result = execute_query(
        variables: { input: { youtubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ" } },
        context: { current_user: user }
      )
      data = result["data"]["createPost"]

      expect(data["title"]).to eq("Rick Astley - Never Gonna Give You Up")
      expect(data["content"]).to eq("The official video for Rick Astley")
      expect(data["embedUrl"]).to eq("https://www.youtube.com/embed/dQw4w9WgXcQ")
      expect(ActionCable.server).to have_received(:broadcast).with("notifications_BTC", hash_including(title: "Rick Astley - Never Gonna Give You Up"))
    end
  end
end

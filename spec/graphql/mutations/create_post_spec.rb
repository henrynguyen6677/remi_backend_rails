# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::CreatePost do
  let(:user) { create(:user) }

  let(:valid_oembed_response) do
    {
      "title" => "Rick Astley - Never Gonna Give You Up",
      "author_name" => "Rick Astley"
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

    it "returns ERROR_VIDEO_RESTRICTED when oEmbed API fails" do
      stub_request(:get, /youtube\.com\/oembed/)
        .to_return(status: 401, body: "Unauthorized")

      result = execute_query(
        variables: { input: { youtubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ" } },
        context: { current_user: user }
      )
      errors = result["errors"]
      expect(errors).to be_present
      expect(errors.first["message"]).to eq("ERROR_VIDEO_RESTRICTED")
    end

    it "creates a post when oEmbed succeeds" do
      stub_request(:get, /youtube\.com\/oembed/)
        .to_return(status: 200, body: valid_oembed_response, headers: { "Content-Type" => "application/json" })

      allow(ActionCable.server).to receive(:broadcast)

      result = execute_query(
        variables: { input: { youtubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ" } },
        context: { current_user: user }
      )
      data = result["data"]["createPost"]

      expect(data["title"]).to eq("Rick Astley - Never Gonna Give You Up")
      expect(data["content"]).to eq("Video by Rick Astley")
      expect(data["embedUrl"]).to eq("https://www.youtube.com/embed/dQw4w9WgXcQ")
      expect(ActionCable.server).to have_received(:broadcast).with("notifications_BTC", hash_including(title: "Rick Astley - Never Gonna Give You Up"))
    end
  end
end

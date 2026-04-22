# frozen_string_literal: true

require "rails_helper"

RSpec.describe YoutubeService do
  describe ".extract_video_id" do
    it "extracts ID from standard watch URL" do
      expect(described_class.extract_video_id("https://www.youtube.com/watch?v=dQw4w9WgXcQ")).to eq("dQw4w9WgXcQ")
    end

    it "extracts ID from short URL" do
      expect(described_class.extract_video_id("https://youtu.be/dQw4w9WgXcQ")).to eq("dQw4w9WgXcQ")
    end

    it "extracts ID from embed URL" do
      expect(described_class.extract_video_id("https://www.youtube.com/embed/dQw4w9WgXcQ")).to eq("dQw4w9WgXcQ")
    end

    it "extracts ID from shorts URL" do
      expect(described_class.extract_video_id("https://www.youtube.com/shorts/dQw4w9WgXcQ")).to eq("dQw4w9WgXcQ")
    end

    it "returns nil for non-YouTube URL" do
      expect(described_class.extract_video_id("https://not-youtube.com/blah")).to be_nil
    end

    it "returns nil for empty string" do
      expect(described_class.extract_video_id("")).to be_nil
    end
  end

  describe ".fetch_video_info" do
    let(:success_body) do
      {
        "items" => [
          {
            "snippet" => {
              "title" => "Test Video",
              "description" => "A test video description",
              "channelTitle" => "TestChannel"
            }
          }
        ]
      }.to_json
    end

    it "returns title, description, and channel_title on success" do
      stub_request(:get, /googleapis\.com\/youtube\/v3\/videos/)
        .to_return(status: 200, body: success_body, headers: { "Content-Type" => "application/json" })

      result = described_class.fetch_video_info("dQw4w9WgXcQ")
      expect(result[:title]).to eq("Test Video")
      expect(result[:description]).to eq("A test video description")
      expect(result[:channel_title]).to eq("TestChannel")
    end

    it "raises ERROR_VIDEO_RESTRICTED on HTTP error" do
      stub_request(:get, /googleapis\.com\/youtube\/v3\/videos/)
        .to_return(status: 403, body: "Forbidden")

      expect {
        described_class.fetch_video_info("private_video")
      }.to raise_error(GraphQL::ExecutionError, "ERROR_VIDEO_RESTRICTED")
    end

    it "raises ERROR_VIDEO_RESTRICTED when items array is empty" do
      stub_request(:get, /googleapis\.com\/youtube\/v3\/videos/)
        .to_return(status: 200, body: { "items" => [] }.to_json, headers: { "Content-Type" => "application/json" })

      expect {
        described_class.fetch_video_info("deleted_video")
      }.to raise_error(GraphQL::ExecutionError, "ERROR_VIDEO_RESTRICTED")
    end
  end

  describe ".embed_url" do
    it "returns the embed URL" do
      expect(described_class.embed_url("dQw4w9WgXcQ")).to eq("https://www.youtube.com/embed/dQw4w9WgXcQ")
    end
  end
end

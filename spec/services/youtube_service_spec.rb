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

  describe ".fetch_oembed" do
    it "returns parsed JSON on success" do
      body = { "title" => "Test", "author_name" => "Author" }.to_json
      stub_request(:get, /youtube\.com\/oembed/)
        .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

      result = described_class.fetch_oembed("dQw4w9WgXcQ")
      expect(result["title"]).to eq("Test")
      expect(result["author_name"]).to eq("Author")
    end

    it "raises ERROR_VIDEO_RESTRICTED on 401" do
      stub_request(:get, /youtube\.com\/oembed/)
        .to_return(status: 401, body: "Unauthorized")

      expect {
        described_class.fetch_oembed("private_video")
      }.to raise_error(GraphQL::ExecutionError, "ERROR_VIDEO_RESTRICTED")
    end

    it "raises ERROR_VIDEO_RESTRICTED on 404" do
      stub_request(:get, /youtube\.com\/oembed/)
        .to_return(status: 404, body: "Not Found")

      expect {
        described_class.fetch_oembed("deleted_video")
      }.to raise_error(GraphQL::ExecutionError, "ERROR_VIDEO_RESTRICTED")
    end
  end

  describe ".embed_url" do
    it "returns the embed URL" do
      expect(described_class.embed_url("dQw4w9WgXcQ")).to eq("https://www.youtube.com/embed/dQw4w9WgXcQ")
    end
  end
end

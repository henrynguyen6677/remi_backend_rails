# frozen_string_literal: true

require "net/http"

class YoutubeService
  YOUTUBE_REGEX = /^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|&v(?:i)?=))([^#&?]*).*/
  API_KEY = ENV.fetch("YOUTUBE_API_KEY", "")

  # Extracts the video ID from a YouTube URL.
  # Returns nil if the URL is not a valid YouTube URL.
  def self.extract_video_id(youtube_url)
    match = youtube_url.match(YOUTUBE_REGEX)
    match ? match[1] : nil
  end

  # Fetches video metadata from YouTube Data API v3.
  # Returns a hash with title, description, and channel_title.
  # Raises specific error codes on failure.
  def self.fetch_video_info(video_id)
    begin
      uri = URI("https://www.googleapis.com/youtube/v3/videos?id=#{video_id}&key=#{API_KEY}&part=snippet")
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        raise ApiErrors::Error, ApiErrors::VIDEO_RESTRICTED
      end

      parsed = JSON.parse(response.body)
      items = parsed["items"]

      if items.nil? || items.empty?
        raise ApiErrors::Error, ApiErrors::VIDEO_RESTRICTED
      end
    rescue StandardError => e
      Rails.logger.error("YouTube API fetching failed: #{e.message}")
      raise ApiErrors::Error, ApiErrors::VIDEO_RESTRICTED
    end

    snippet = items.first["snippet"]
    {
      title: snippet["title"],
      description: snippet["description"] || "",
      channel_title: snippet["channelTitle"] || ""
    }
  end

  # Builds embed URL from a video ID.
  def self.embed_url(video_id)
    "https://www.youtube.com/embed/#{video_id}"
  end
end

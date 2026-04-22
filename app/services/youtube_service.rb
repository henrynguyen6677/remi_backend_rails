# frozen_string_literal: true

require "net/http"

class YoutubeService
  YOUTUBE_REGEX = /^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|&v(?:i)?=))([^#&?]*).*/

  # Extracts the video ID from a YouTube URL.
  # Returns nil if the URL is not a valid YouTube URL.
  def self.extract_video_id(youtube_url)
    match = youtube_url.match(YOUTUBE_REGEX)
    match ? match[1] : nil
  end

  # Fetches video metadata (title, author) from YouTube oEmbed API.
  # Raises specific error codes on failure.
  def self.fetch_oembed(video_id)
    uri = URI("https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=#{video_id}&format=json")
    response = Net::HTTP.get_response(uri)

    unless response.is_a?(Net::HTTPSuccess)
      raise GraphQL::ExecutionError, "ERROR_VIDEO_RESTRICTED"
    end

    JSON.parse(response.body)
  end

  # Builds embed URL from a video ID.
  def self.embed_url(video_id)
    "https://www.youtube.com/embed/#{video_id}"
  end
end

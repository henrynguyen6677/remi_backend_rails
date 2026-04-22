require 'net/http'

# frozen_string_literal: true

module Mutations
  class CreatePost < Mutations::BaseMutation
    argument :create_post_input, Types::CreatePostInputType, required: true
    type Types::PostResponseType

    def resolve(create_post_input:)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user
      pp create_post_input
      youtube_url = create_post_input.youtube_url
      regex = /^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*/
      match = youtube_url.match(regex)
      post_id = match ? match[1] : nil
      if post_id.blank?
        raise GraphQL::ExecutionError, "ERROR_INVALID_YOUTUBE_URL"
      end
      embed_url = "https://www.youtube.com/embed/#{post_id}"

      uri = URI("https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=#{post_id}&format=json")
      response = Net::HTTP.get_response(uri)
      
      unless response.is_a?(Net::HTTPSuccess)
        raise GraphQL::ExecutionError, "Failed to parse YouTube oEmbed response"
      end
      parsed = JSON.parse(response.body)
      title = parsed["title"]
      content = parsed["author_name"] ? "Video by #{parsed["author_name"]}" : ""

      post = Post.find_or_initialize_by(post_id: post_id)
      post.update!(
        title: title,
        content: content,
        embedUrl: embed_url,
        url: youtube_url,
        user_id: user.user_id
       )
      # Broadcast the new post to all subscribers for room BTC
      ActionCable.server.broadcast(
        "notifications_BTC",
        {
          title: title,
          email: user.email,
        }
      )
      post
    end
  end
end

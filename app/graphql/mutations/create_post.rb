# frozen_string_literal: true

module Mutations
  class CreatePost < Mutations::BaseMutation
    argument :create_post_input, Types::CreatePostInputType, required: true
    type Types::PostResponseType

    def resolve(create_post_input:)
      user = context[:current_user]
      raise ApiErrors::Error, ApiErrors::UNAUTHORIZED unless user

      post = create_and_save_post(create_post_input.youtube_url, user)
      broadcast_notification(post, user)

      post
    end

    private

    def create_and_save_post(youtube_url, user)
      video_id = YoutubeService.extract_video_id(youtube_url)
      raise ApiErrors::Error, ApiErrors::INVALID_YOUTUBE_URL if video_id.blank?

      video_info = YoutubeService.fetch_video_info(video_id)

      Post.find_or_initialize_by(post_id: video_id).tap do |post|
        post.update!(
          title: video_info[:title],
          content: video_info[:description],
          embedUrl: YoutubeService.embed_url(video_id),
          url: youtube_url,
          user_id: user.user_id
        )
      end
    end

    def broadcast_notification(post, user)
      ActionCable.server.broadcast(
        "notifications_BTC",
        { title: post.title, email: user.email }
      )
    end
  end
end

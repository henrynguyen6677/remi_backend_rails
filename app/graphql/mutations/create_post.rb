# frozen_string_literal: true

module Mutations
  class CreatePost < Mutations::BaseMutation
    argument :create_post_input, Types::CreatePostInputType, required: true
    type Types::PostResponseType

    def resolve(create_post_input:)
      user = context[:current_user]
      raise ApiErrors::Error, ApiErrors::UNAUTHORIZED unless user

      youtube_url = create_post_input.youtube_url
      video_id = YoutubeService.extract_video_id(youtube_url)
      raise ApiErrors::Error, ApiErrors::INVALID_YOUTUBE_URL if video_id.blank?

      video_info = YoutubeService.fetch_video_info(video_id)
      title = video_info[:title]
      content = video_info[:description]

      post = Post.find_or_initialize_by(post_id: video_id)
      post.update!(
        title: title,
        content: content,
        embedUrl: YoutubeService.embed_url(video_id),
        url: youtube_url,
        user_id: user.user_id
      )

      ActionCable.server.broadcast(
        "notifications_BTC",
        { title: title, email: user.email }
      )

      post
    end
  end
end

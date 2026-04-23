module ApiErrors
  USER_HAS_EXIST = { code: "ERROR_USER_HAS_EXIST", message: "This email is already registered." }
  PASSWORD_TOO_SHORT = { code: "ERROR_PASSWORD_TOO_SHORT", message: "Password must be at least 6 characters long." }
  INVALID_YOUTUBE_URL = { code: "ERROR_INVALID_YOUTUBE_URL", message: "The YouTube URL provided is invalid." }
  VIDEO_RESTRICTED = { code: "ERROR_VIDEO_RESTRICTED", message: "This video is unavailable, private, or does not allow embedding." }
  UNAUTHORIZED = { code: "ERROR_UNAUTHORIZED", message: "You must be logged in to perform this action." }
  POST_NOT_FOUND = { code: "ERROR_POST_NOT_FOUND", message: "Post not found." }

  class Error < GraphQL::ExecutionError
    def initialize(error_obj)
      super(error_obj[:message], extensions: { code: error_obj[:code] })
    end
  end
end

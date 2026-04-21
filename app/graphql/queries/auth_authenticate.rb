module Queries
  class AuthAuthenticate < GraphQL::Schema::Resolver
    argument :input, Types::AuthenticateInputInputType, required: true
    type Types::AuthenticateResponseType, null: false

    def resolve(input:)
      user = User.find_by(email: input.email.downcase.strip)
      unless user&.authenticate(input.password)
        raise GraphQL::ExecutionError, "ERROR_WRONG_PASSWORD"
      end
      token = JwtService.encode({ userId: user.user_id, email: user.email })
      pp token
      {
        access_token: token,
        email: user.email,
        user_id: user.user_id,
        created_at: user.created_at
      }
    end
  end
end

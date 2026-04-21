# frozen_string_literal: true

module Mutations
  class AuthRegister < BaseMutation
    argument :input, Types::RegisterInputInputType, required: true
    type Types::AuthenticateResponseType

    def resolve(input:)
      email = input.email.downcase.strip
      password = input.password
      if User.exists?(email: email)     
        raise GraphQL::ExecutionError, "ERROR_USER_HAS_EXIST"
      end

      user = User.create!(
        email: email,
        password: BCrypt::Password.create(password),
      )
      token = JwtService.encode({ userId: user.user_id, email: user.email })

      {
        access_token: token,
        email: user.email,
        user_id: user.user_id,
        created_at: user.created_at,
      }
    end
  end
end

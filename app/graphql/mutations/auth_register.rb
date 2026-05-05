module Mutations
  class AuthRegister < BaseMutation
    argument :input, Types::RegisterInputType, required: true
    type Types::AuthenticateResponseType

    def resolve(input:)
      email = input.email.downcase.strip
      password = input.password
      existing_user = User.find_by(email: email)
      if existing_user
        unless BCrypt::Password.new(existing_user.password) == password
          raise ApiErrors::Error, ApiErrors::INVALID_CREDENTIALS
        end
        user = existing_user
      else
        if password.length < 6
          raise ApiErrors::Error, ApiErrors::PASSWORD_TOO_SHORT
        end

        user = User.create!(
          email: email,
          password: BCrypt::Password.create(password),
        )
      end
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

# frozen_string_literal: true

class JwtService
  SECRET = ENV.fetch("JWT_SECRET", "default_secret")
  ALGORITHM = "HS256"

  def self.encode(payload)
    payload[:exp] = 30.days.from_now.to_i
    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET, true, { algorithm: ALGORITHM }).first
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    raise GraphQL::ExecutionError, "Invalid token: #{e.message}"
  end
end

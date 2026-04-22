# frozen_string_literal: true

require "rails_helper"

RSpec.describe Queries::AuthAuthenticate do
  let(:plain_password) { "password123" }
  let!(:user) { create(:user, email: "auth@example.com", password: BCrypt::Password.create(plain_password)) }

  def execute_query(variables: {})
    query = <<~GQL
      query authenticate($input: AuthenticateInput!) {
        authAuthenticate(input: $input) {
          email
          userId
          accessToken
        }
      }
    GQL
    BackendRailsSchema.execute(query, variables: variables, context: {})
  end

  describe "resolve" do
    it "returns auth data for correct credentials" do
      result = execute_query(variables: { input: { email: "auth@example.com", password: plain_password } })
      data = result["data"]["authAuthenticate"]

      expect(data["email"]).to eq("auth@example.com")
      expect(data["userId"]).to eq(user.user_id)
      expect(data["accessToken"]).to be_present
    end

    it "returns error for wrong password" do
      result = execute_query(variables: { input: { email: "auth@example.com", password: "wrongpass" } })

      errors = result["errors"]
      expect(errors).to be_present
      expect(errors.first["message"]).to eq("ERROR_WRONG_PASSWORD")
    end

    it "returns error for non-existent user" do
      result = execute_query(variables: { input: { email: "nobody@example.com", password: "anything" } })

      errors = result["errors"]
      expect(errors).to be_present
      expect(errors.first["message"]).to eq("ERROR_WRONG_PASSWORD")
    end
  end
end

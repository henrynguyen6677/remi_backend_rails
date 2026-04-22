# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::AuthRegister do
  def execute_query(variables: {})
    query = <<~GQL
      mutation register($input: RegisterInput!) {
        authRegister(input: $input) {
          email
          userId
          accessToken
        }
      }
    GQL
    BackendRailsSchema.execute(query, variables: variables, context: {})
  end

  describe "resolve" do
    it "registers a new user and returns auth data" do
      result = execute_query(variables: { input: { email: "newuser@example.com", password: "pass123" } })
      data = result["data"]["authRegister"]

      expect(data["email"]).to eq("newuser@example.com")
      expect(data["userId"]).to be_present
      expect(data["accessToken"]).to be_present
    end

    it "normalizes email to lowercase and stripped" do
      result = execute_query(variables: { input: { email: "  FOO@Bar.COM  ", password: "pass123" } })
      data = result["data"]["authRegister"]

      expect(data["email"]).to eq("foo@bar.com")
    end

    it "returns error when email already exists" do
      create(:user, email: "existing@example.com")
      result = execute_query(variables: { input: { email: "existing@example.com", password: "pass123" } })

      errors = result["errors"]
      expect(errors).to be_present
      expect(errors.first["message"]).to eq("ERROR_USER_HAS_EXIST")
    end
  end
end

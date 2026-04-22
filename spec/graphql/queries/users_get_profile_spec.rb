# frozen_string_literal: true

require "rails_helper"

RSpec.describe Queries::UsersGetProfile do
  let(:user) { create(:user) }

  def execute_query(context: {})
    query = <<~GQL
      query {
        usersGetprofile {
          email
          userId
        }
      }
    GQL
    BackendRailsSchema.execute(query, context: context)
  end

  describe "resolve" do
    it "returns user profile when authenticated" do
      result = execute_query(context: { current_user: user })
      data = result["data"]["usersGetprofile"]

      expect(data["email"]).to eq(user.email)
      expect(data["userId"]).to eq(user.user_id)
    end

    it "returns Unauthorized when not authenticated" do
      result = execute_query(context: { current_user: nil })

      errors = result["errors"]
      expect(errors).to be_present
      expect(errors.first["message"]).to eq("Unauthorized")
    end
  end
end

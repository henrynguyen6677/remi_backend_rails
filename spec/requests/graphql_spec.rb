# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GraphQL requests", type: :request do
  let(:user) { create(:user) }

  let(:posts_query) do
    <<~GQL
      query posts($input: FindAllInput) {
        posts(findAllInput: $input) {
          postId
          title
        }
      }
    GQL
  end

  describe "POST /graphql" do
    it "works without Authorization header (current_user is nil)" do
      post "/graphql",
        params: { query: posts_query, variables: { input: { take: 10, skip: 0 } } }.to_json,
        headers: { "Content-Type" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]).to have_key("posts")
    end

    it "works with a valid token (current_user is set)" do
      token = JwtService.encode({ userId: user.user_id, email: user.email })
      profile_query = <<~GQL
        query {
          usersGetprofile {
            email
          }
        }
      GQL

      post "/graphql",
        params: { query: profile_query }.to_json,
        headers: { "Content-Type" => "application/json", "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]["usersGetprofile"]["email"]).to eq(user.email)
    end

    it "does NOT block request with an invalid token (current_user stays nil)" do
      post "/graphql",
        params: { query: posts_query, variables: { input: { take: 10, skip: 0 } } }.to_json,
        headers: { "Content-Type" => "application/json", "Authorization" => "Bearer invalid.token.here" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      # Public query still works — no auth error raised
      expect(json["data"]).to have_key("posts")
    end
  end
end

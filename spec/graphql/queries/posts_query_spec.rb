# frozen_string_literal: true

require "rails_helper"

RSpec.describe Queries::PostsQuery do
  let(:user) { create(:user) }

  def execute_query(variables: {}, context: {})
    query = <<~GQL
      query posts($input: FindAllInput) {
        posts(findAllInput: $input) {
          postId
          title
        }
      }
    GQL
    BackendRailsSchema.execute(query, variables: variables, context: context)
  end

  describe "resolve" do
    before do
      3.times do |i|
        create(:post, post_id: "vid_#{i}", user: user, created_at: i.days.ago)
      end
    end

    it "returns posts in descending order by created_at" do
      result = execute_query(variables: { input: { take: 10, skip: 0 } })
      data = result["data"]["posts"]

      expect(data.length).to eq(3)
      expect(data.first["postId"]).to eq("vid_0") # most recent
    end

    it "respects take and skip pagination" do
      result = execute_query(variables: { input: { take: 1, skip: 1 } })
      data = result["data"]["posts"]

      expect(data.length).to eq(1)
      expect(data.first["postId"]).to eq("vid_1")
    end

    it "returns up to 10 posts by default when no input" do
      result = execute_query(variables: {})
      data = result["data"]["posts"]

      expect(data.length).to eq(3)
    end
  end
end

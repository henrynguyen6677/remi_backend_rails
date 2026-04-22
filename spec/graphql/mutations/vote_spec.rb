# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::Vote do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:post_record) { create(:post, user: user, like_user_ids: [], dislike_user_ids: []) }

  def execute_query(variables: {}, context: {})
    query = <<~GQL
      mutation vote($input: CreateVoteInput!) {
        vote(createVoteInput: $input) {
          postId
          vote {
            up
            down
          }
        }
      }
    GQL
    BackendRailsSchema.execute(query, variables: variables, context: context)
  end

  describe "resolve" do
    it "returns Unauthorized when no user in context" do
      result = execute_query(
        variables: { input: { postId: post_record.post_id, vote: "UP" } },
        context: { current_user: nil }
      )
      expect(result["errors"].first["message"]).to eq("Unauthorized")
    end

    it "adds user to like_user_ids on UP vote" do
      execute_query(
        variables: { input: { postId: post_record.post_id, vote: "UP" } },
        context: { current_user: user }
      )
      post_record.reload
      expect(post_record.like_user_ids).to include(user.user_id.to_s)
      expect(post_record.dislike_user_ids).not_to include(user.user_id.to_s)
    end

    it "removes user from like_user_ids on second UP vote (toggle off)" do
      post_record.update(like_user_ids: [user.user_id.to_s])

      execute_query(
        variables: { input: { postId: post_record.post_id, vote: "UP" } },
        context: { current_user: user }
      )
      post_record.reload
      expect(post_record.like_user_ids).not_to include(user.user_id.to_s)
    end

    it "switches from like to dislike on DOWN vote" do
      post_record.update(like_user_ids: [user.user_id.to_s])

      execute_query(
        variables: { input: { postId: post_record.post_id, vote: "DOWN" } },
        context: { current_user: user }
      )
      post_record.reload
      expect(post_record.like_user_ids).not_to include(user.user_id.to_s)
      expect(post_record.dislike_user_ids).to include(user.user_id.to_s)
    end

    it "removes user from dislike_user_ids on second DOWN vote (toggle off)" do
      post_record.update(dislike_user_ids: [user.user_id.to_s])

      execute_query(
        variables: { input: { postId: post_record.post_id, vote: "DOWN" } },
        context: { current_user: user }
      )
      post_record.reload
      expect(post_record.dislike_user_ids).not_to include(user.user_id.to_s)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Post, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      post = build(:post)
      expect(post).to be_valid
    end

    it "is invalid without a url" do
      post = build(:post, url: nil)
      expect(post).not_to be_valid
      expect(post.errors[:url]).to include("can't be blank")
    end

    it "is invalid without a title" do
      post = build(:post, title: nil)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include("can't be blank")
    end

    it "is invalid without content" do
      post = build(:post, content: nil)
      expect(post).not_to be_valid
      expect(post.errors[:content]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to a user" do
      assoc = described_class.reflect_on_association(:user)
      expect(assoc.macro).to eq(:belongs_to)
    end
  end
end

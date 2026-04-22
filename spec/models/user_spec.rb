# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "is invalid without an email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is invalid without a password" do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "is invalid with a duplicate email" do
      create(:user, email: "dup@example.com")
      user = build(:user, email: "dup@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end
  end

  describe "associations" do
    it "has many posts" do
      assoc = described_class.reflect_on_association(:posts)
      expect(assoc.macro).to eq(:has_many)
    end
  end

  describe "#authenticate" do
    let(:plain_password) { "password123" }
    let(:user) { create(:user, password: BCrypt::Password.create(plain_password)) }

    it "returns true for correct password" do
      expect(user.authenticate(plain_password)).to be true
    end

    it "returns false for wrong password" do
      expect(user.authenticate("wrong_password")).to be false
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe JwtService do
  let(:payload) { { userId: 1, email: "test@example.com" } }

  describe ".encode" do
    it "returns a JWT string" do
      token = described_class.encode(payload)
      expect(token).to be_a(String)
      expect(token.split(".").length).to eq(3)
    end
  end

  describe ".decode" do
    it "returns the original payload with indifferent access" do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)

      expect(decoded[:userId]).to eq(1)
      expect(decoded["userId"]).to eq(1)
      expect(decoded[:email]).to eq("test@example.com")
    end

    it "raises an error for an invalid token" do
      expect {
        described_class.decode("invalid.token.here")
      }.to raise_error(GraphQL::ExecutionError, /Invalid token/)
    end

    it "raises an error for a tampered token" do
      token = described_class.encode(payload)
      tampered = token[0...-5] + "XXXXX"

      expect {
        described_class.decode(tampered)
      }.to raise_error(GraphQL::ExecutionError, /Invalid token/)
    end
  end
end

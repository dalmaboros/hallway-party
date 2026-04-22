# frozen_string_literal: true

require "rails_helper"

RSpec.describe HobbyEmbeddingService do
  describe ".call", :vcr do
    subject(:embedding) { described_class.call("knitting") }

    it "returns an array" do
      expect(embedding).to be_an(Array)
    end

    it "returns a #{HobbyEmbeddingService::DIMENSIONS}-dimension vector" do
      expect(embedding.size).to eq(HobbyEmbeddingService::DIMENSIONS)
    end

    it "returns floats" do
      expect(embedding).to all(be_a(Float))
    end
  end
end

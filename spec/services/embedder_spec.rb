# frozen_string_literal: true

require "rails_helper"

RSpec.describe Embedder do
  describe "#embed", :vcr do
    subject(:vector) { described_class.new("knitting").embed }

    it "returns an array" do
      expect(vector).to be_an(Array)
    end

    it "returns a #{Embedder::DIMENSIONS}-dimension vector" do
      expect(vector.size).to eq(Embedder::DIMENSIONS)
    end

    it "returns floats" do
      expect(vector).to all(be_a(Float))
    end
  end
end

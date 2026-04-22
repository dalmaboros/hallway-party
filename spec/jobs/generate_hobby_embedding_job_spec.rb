# frozen_string_literal: true

require "rails_helper"

RSpec.describe GenerateHobbyEmbeddingJob do
  describe "#perform" do
    let(:hobby) { create(:hobby, name: "knitting", embedding: nil) }
    let(:fake_embedding) { Array.new(HobbyEmbeddingService::DIMENSIONS, 0.1) }

    before do
      allow(HobbyEmbeddingService).to receive(:call).with("knitting").and_return(fake_embedding)
    end

    it "populates the hobby's embedding" do
      described_class.perform_now(hobby)

      expect(hobby.reload.embedding.to_a).to eq(fake_embedding)
    end

    it "calls HobbyEmbeddingService with the hobby name" do
      described_class.perform_now(hobby)

      expect(HobbyEmbeddingService).to have_received(:call).with("knitting")
    end
  end
end

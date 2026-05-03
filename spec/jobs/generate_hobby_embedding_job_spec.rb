# frozen_string_literal: true

require "rails_helper"

RSpec.describe GenerateHobbyEmbeddingJob do
  describe "#perform" do
    let(:hobby) { create(:hobby, name: "knitting", embedding: nil) }
    let(:fake_embedding) { Array.new(Embedder::DIMENSIONS, 0.1) }
    let(:embedder) { instance_double(Embedder, embed: fake_embedding) }

    before do
      allow(Embedder).to receive(:new).with("knitting").and_return(embedder)
    end

    it "populates the hobby's embedding" do
      described_class.perform_now(hobby)

      expect(hobby.reload.embedding.to_a).to eq(fake_embedding)
    end

    it "computes the embedding from the hobby name" do
      described_class.perform_now(hobby)

      expect(Embedder).to have_received(:new).with("knitting")
    end
  end
end

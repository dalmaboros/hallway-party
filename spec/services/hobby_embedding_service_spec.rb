# frozen_string_literal: true

require "rails_helper"

RSpec.describe HobbyEmbeddingService do
  # WebMock-stubbed because OPENAI_API_KEY is not yet provisioned in .env.
  # Once the real key is set up, convert to a captured VCR cassette: delete the
  # `before` stub, add `:vcr` metadata to `describe ".call"`, and run once to record.
  describe ".call" do
    let(:fake_embedding) { Array.new(HobbyEmbeddingService::DIMENSIONS, 0.01) }

    before do
      stub_request(:post, "https://api.openai.com/v1/embeddings")
        .to_return(
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: { data: [{ embedding: fake_embedding }] }.to_json,
        )
    end

    it "returns the embedding array from the OpenAI response" do
      expect(described_class.call("knitting")).to eq(fake_embedding)
    end

    it "posts the hobby name and model to OpenAI" do
      described_class.call("knitting")

      expect(WebMock).to have_requested(:post, "https://api.openai.com/v1/embeddings")
        .with(body: hash_including(model: HobbyEmbeddingService::MODEL, input: "knitting"))
    end
  end
end

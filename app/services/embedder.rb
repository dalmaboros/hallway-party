# frozen_string_literal: true

class Embedder
  MODEL = "text-embedding-3-small"
  DIMENSIONS = 1536

  def initialize(text)
    @text = text
  end

  def embed
    response = client.embeddings(parameters: { model: MODEL, input: @text })
    response.dig("data", 0, "embedding")
  end

  private

  def client
    @client ||= OpenAI::Client.new
  end
end

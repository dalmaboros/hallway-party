# frozen_string_literal: true

class HobbyEmbeddingService
  MODEL = "text-embedding-3-small"
  DIMENSIONS = 1536

  class << self
    def call(text)
      new(text).call
    end
  end

  def initialize(text)
    @text = text
  end

  def call
    response = client.embeddings(parameters: { model: MODEL, input: @text })
    response.dig("data", 0, "embedding")
  end

  private

  def client
    @client ||= OpenAI::Client.new
  end
end

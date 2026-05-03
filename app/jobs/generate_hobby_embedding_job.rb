# frozen_string_literal: true

class GenerateHobbyEmbeddingJob < ApplicationJob
  queue_as :default

  def perform(hobby)
    hobby.update!(embedding: Embedder.new(hobby.name).embed)
  end
end

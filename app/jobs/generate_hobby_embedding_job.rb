# frozen_string_literal: true

class GenerateHobbyEmbeddingJob < ApplicationJob
  queue_as :default

  def perform(hobby)
    hobby.update!(embedding: HobbyEmbeddingService.call(hobby.name))
  end
end

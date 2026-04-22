# frozen_string_literal: true

namespace :hobbies do
  desc "Generate embeddings synchronously for every Hobby whose embedding is nil"
  task backfill_embeddings: :environment do
    pending = Hobby.where(embedding: nil)
    total = pending.count

    if total.zero?
      puts "No hobbies pending embedding. All set."
      next
    end

    puts "Generating embeddings for #{total} hobby/hobbies (synchronous)..."
    pending.find_each.with_index(1) do |hobby, i|
      GenerateHobbyEmbeddingJob.perform_now(hobby)
      puts "  [#{i}/#{total}] #{hobby.name}"
    end
    puts "Done."
  end
end

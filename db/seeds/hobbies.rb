# frozen_string_literal: true

# Hobbies are seeded with real OpenAI embeddings captured from dev (see
# db/seeds/hobbies.json), so contributors without an OPENAI_API_KEY still get
# a fully-working AttendeeMatcher out of the box. Regenerate with:
#
#   bin/rails runner 'File.write("db/seeds/hobbies.json", JSON.generate(Hobby.order(:name).map { |h| { name: h.name, embedding: h.embedding.to_a } }))'

require "json"

puts "Seeding hobbies..."

seeds = JSON.parse(Rails.root.join("db/seeds/hobbies.json").read)

seeds.each do |seed|
  hobby = Hobby.find_or_initialize_by(name: seed.fetch("name"))
  hobby.embedding = seed.fetch("embedding") if hobby.embedding.blank?
  hobby.save!
end

puts "✓ Seeded #{Hobby.count} hobbies"

# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Idempotent seeds — safe to re-run. Uses find_or_create_by to avoid duplicates.

puts "Seeding events..."

Event.find_or_create_by!(name: "RubyConfAT 2026") do |event|
  event.website = "https://rubyconf.at/"
  event.location = "Vienna, Austria"
  event.time_zone = "Europe/Vienna"
  event.starts_at = Time.zone.parse("2026-05-28 09:00")
  event.ends_at = Time.zone.parse("2026-05-30 18:00")
end

Event.find_or_create_by!(name: "RubyConf 2026") do |event|
  event.website = "https://rubyconf.org/"
  event.location = "Las Vegas, NV"
  event.time_zone = "America/Los_Angeles"
  event.starts_at = Time.zone.parse("2026-07-14 09:00")
  event.ends_at = Time.zone.parse("2026-07-16 18:00")
end

puts "✓ Seeded #{Event.count} event(s)"

puts "Seeding hobbies..."

HOBBIES = [
  "hiking",
  "cycling",
  "rock climbing",
  "running",
  "skiing",
  "surfing",
  "knitting",
  "pottery",
  "woodworking",
  "sewing",
  "fiber arts",
  "cooking",
  "baking",
  "fermentation",
  "coffee",
  "playing guitar",
  "piano",
  "singing",
  "board games",
  "video games",
  "chess",
  "tabletop RPGs",
  "photography",
  "painting",
  "drawing",
  "creative writing",
  "gardening",
  "birdwatching",
  "yoga",
  "reading",
  "travel",
].freeze

HOBBIES.each { |name| Hobby.find_or_create_by!(name: name) }

puts "✓ Seeded #{Hobby.count} hobby/hobbies"

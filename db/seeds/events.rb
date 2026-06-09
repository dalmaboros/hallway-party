# frozen_string_literal: true

puts "Seeding events..."

Event.find_or_create_by!(name: "RubyConfAT 2026") do |event|
  event.website = "https://rubyconf.at/"
  event.location = "Vienna, Austria"
  event.time_zone = "Europe/Vienna"
  event.starts_at = Time.zone.parse("2026-05-29 09:00")
  event.ends_at = Time.zone.parse("2026-05-31 18:00")
end

Event.find_or_create_by!(name: "RubyConf 2026") do |event|
  event.website = "https://rubyconf.org/"
  event.location = "Las Vegas, NV"
  event.time_zone = "America/Los_Angeles"
  event.starts_at = Time.zone.parse("2026-07-14 09:00")
  event.ends_at = Time.zone.parse("2026-07-16 18:00")
end

Event.find_or_create_by!(name: "SF Ruby 2025") do |event|
  event.website = "https://sfruby.com"
  event.location = "San Francisco, CA"
  event.time_zone = "America/Los_Angeles"
  event.starts_at = Time.zone.parse("2025-11-19 09:00")
  event.ends_at = Time.zone.parse("2025-11-20 18:00")
end

Event.find_or_create_by!(name: "EuRuKo 2025") do |event|
  event.website = "https://2025.euruko.org"
  event.location = "Viana do Castelo, Portugal"
  event.time_zone = "Europe/Lisbon"
  event.starts_at = Time.zone.parse("2025-09-18 09:00")
  event.ends_at = Time.zone.parse("2025-09-19 18:00")
end

Event.find_or_create_by!(name: "RailsConf 2025") do |event|
  event.website = "https://railsconf.org"
  event.location = "Philadelphia, PA"
  event.time_zone = "America/New_York"
  event.starts_at = Time.zone.parse("2025-07-08 09:00")
  event.ends_at = Time.zone.parse("2025-07-10 18:00")
end

Event.find_or_create_by!(name: "Blastoff Rails 2026") do |event|
  event.website = "https://blastoffrails.com"
  event.location = "Albuquerque, NM"
  event.time_zone = "America/Denver"
  event.starts_at = Time.zone.parse("2026-06-11 09:00")
  event.ends_at = Time.zone.parse("2026-06-12 18:00")
end

Event.find_or_create_by!(name: "Brighton Ruby 2026") do |event|
  event.website = "https://brightonruby.com"
  event.location = "Brighton, United Kingdom"
  event.time_zone = "Europe/London"
  event.starts_at = Time.zone.parse("2026-06-25 09:00")
  event.ends_at = Time.zone.parse("2026-06-25 18:00")
end

puts "✓ Seeded #{Event.count} event(s)"

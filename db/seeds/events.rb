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

puts "✓ Seeded #{Event.count} event(s)"

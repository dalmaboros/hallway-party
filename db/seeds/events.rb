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

Event.find_or_create_by!(name: "Rails World 2026") do |event|
  event.website = "https://rubyonrails.org/world/"
  event.location = "Austin, TX"
  event.time_zone = "America/Chicago"
  event.starts_at = Time.zone.parse("2026-09-23 09:00")
  event.ends_at = Time.zone.parse("2026-09-24 18:00")
end

Event.find_or_create_by!(name: "Rocky Mountain Ruby 2026") do |event|
  event.website = "https://rockymtnruby.dev/"
  event.location = "Boulder, CO"
  event.time_zone = "America/Denver"
  event.starts_at = Time.zone.parse("2026-09-28 09:00")
  event.ends_at = Time.zone.parse("2026-09-29 18:00")
end

Event.find_or_create_by!(name: 'tiny ruby #{conf} 2026') do |event|
  event.website = "https://helsinkiruby.fi/tinyruby/"
  event.location = "Helsinki, Finland"
  event.time_zone = "Europe/Helsinki"
  event.starts_at = Time.zone.parse("2026-10-01 09:00")
  event.ends_at = Time.zone.parse("2026-10-01 18:00")
end

Event.find_or_create_by!(name: "XO Ruby Toronto 2026") do |event|
  event.website = "https://www.xoruby.com/event/toronto-2/"
  event.location = "Toronto, Canada"
  event.time_zone = "America/New_York"
  event.starts_at = Time.zone.parse("2026-10-03 09:00")
  event.ends_at = Time.zone.parse("2026-10-03 18:00")
end

Event.find_or_create_by!(name: "Deccan Queen on Rails 2026") do |event|
  event.website = "https://deccanqueenonrails.com/"
  event.location = "Pune, India"
  event.time_zone = "Asia/Kolkata"
  event.starts_at = Time.zone.parse("2026-10-08 09:00")
  event.ends_at = Time.zone.parse("2026-10-09 18:00")
end

Event.find_or_create_by!(name: "XO Ruby New York City 2026") do |event|
  event.website = "https://www.xoruby.com/event/new-york-city/"
  event.location = "New York, NY"
  event.time_zone = "America/New_York"
  event.starts_at = Time.zone.parse("2026-10-10 09:00")
  event.ends_at = Time.zone.parse("2026-10-10 18:00")
end

Event.find_or_create_by!(name: "Kaigi on Rails 2026") do |event|
  event.website = "https://kaigionrails.org/2026/"
  event.location = "Tokyo, Japan"
  event.time_zone = "Asia/Tokyo"
  event.starts_at = Time.zone.parse("2026-10-16 09:00")
  event.ends_at = Time.zone.parse("2026-10-17 18:00")
end

Event.find_or_create_by!(name: "XO Ruby Montréal 2026") do |event|
  event.website = "https://www.xoruby.com/event/montreal-2/"
  event.location = "Montréal, Canada"
  event.time_zone = "America/New_York"
  event.starts_at = Time.zone.parse("2026-10-17 09:00")
  event.ends_at = Time.zone.parse("2026-10-17 18:00")
end

Event.find_or_create_by!(name: "Trem on Rails 2026") do |event|
  event.website = "https://www.sympla.com.br/evento/meetup-do-trem-on-rails/3559255"
  event.location = "Belo Horizonte, Brazil"
  event.time_zone = "America/Sao_Paulo"
  event.starts_at = Time.zone.parse("2026-10-17 09:00")
  event.ends_at = Time.zone.parse("2026-10-17 18:00")
end

Event.find_or_create_by!(name: "PicoRubyKaigi 2026 Assemble") do |event|
  event.website = "https://picorubykaigi.org"
  event.location = "Tokyo, Japan"
  event.time_zone = "Asia/Tokyo"
  event.starts_at = Time.zone.parse("2026-10-31 09:00")
  event.ends_at = Time.zone.parse("2026-10-31 18:00")
end

Event.find_or_create_by!(name: "San Francisco Ruby Conference 2026") do |event|
  event.website = "https://sfruby.com"
  event.location = "San Francisco, CA"
  event.time_zone = "America/Los_Angeles"
  event.starts_at = Time.zone.parse("2026-11-10 09:00")
  event.ends_at = Time.zone.parse("2026-11-12 18:00")
end

Event.find_or_create_by!(name: "Helvetic Ruby 2026") do |event|
  event.website = "https://helvetic-ruby.ch"
  event.location = "Zurich, Switzerland"
  event.time_zone = "Europe/Zurich"
  event.starts_at = Time.zone.parse("2026-11-19 09:00")
  event.ends_at = Time.zone.parse("2026-11-20 18:00")
end

Event.find_or_create_by!(name: "RubyConf India 2026") do |event|
  event.website = "https://rubyconf.in"
  event.location = "Hyderabad, India"
  event.time_zone = "Asia/Kolkata"
  event.starts_at = Time.zone.parse("2026-11-21 09:00")
  event.ends_at = Time.zone.parse("2026-11-21 18:00")
end

Event.find_or_create_by!(name: "RubyWorld Conference 2026") do |event|
  event.website = "https://2026.rubyworld-conf.org/en/"
  event.location = "Matsue, Japan"
  event.time_zone = "Asia/Tokyo"
  event.starts_at = Time.zone.parse("2026-12-03 09:00")
  event.ends_at = Time.zone.parse("2026-12-04 18:00")
end

Event.find_or_create_by!(name: "Tropical on Rails 2027") do |event|
  event.website = "https://www.tropicalonrails.com/en/2027"
  event.location = "São Paulo, Brazil"
  event.time_zone = "America/Sao_Paulo"
  event.starts_at = Time.zone.parse("2027-03-18 09:00")
  event.ends_at = Time.zone.parse("2027-03-19 18:00")
end

Event.find_or_create_by!(name: "RubyKaigi 2027") do |event|
  event.website = "https://rubykaigi.org/2027/"
  event.location = "Miyazaki, Japan"
  event.time_zone = "Asia/Tokyo"
  event.starts_at = Time.zone.parse("2027-04-14 09:00")
  event.ends_at = Time.zone.parse("2027-04-16 18:00")
end

Event.find_or_create_by!(name: "wroclove.rb 2027") do |event|
  event.website = "https://wrocloverb.com"
  event.location = "Wrocław, Poland"
  event.time_zone = "Europe/Warsaw"
  event.starts_at = Time.zone.parse("2027-04-23 09:00")
  event.ends_at = Time.zone.parse("2027-04-25 18:00")
end

puts "✓ Seeded #{Event.count} event(s)"

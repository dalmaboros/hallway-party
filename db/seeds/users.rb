# frozen_string_literal: true

SEED_USER_COUNT = 8

RANDOM = Random.new(42)
Faker::Config.random = RANDOM

def slugify(name)
  name.downcase.gsub(/[^a-z0-9]+/, "_").squeeze("_")
end

def seed_user(name:)
  username = slugify(name)

  # Seed users use `provider: "seed"` so they never collide with real GitHub sign-ins
  user = User.find_or_create_by!(provider: "seed", uid: username) do |u|
    u.name = name
    u.username = username
    u.email = "#{username}@example.invalid"
  end

  # Backfill profile fields when missing (covers both new and previously-seeded users)
  if user.bio.blank?
    user.update!(
      bio: Faker::Lorem.paragraph(sentence_count: 2),
      website: "https://#{username}.example",
      twitter_url: "https://twitter.com/#{username}",
    )
  end

  if user.location.blank?
    user.update!(location: "#{Faker::Address.city}, #{Faker::Address.state_abbr}")
  end

  user
end

def attend_event(user, event)
  EventAttendance.find_or_create_by!(user: user, event: event)
end

def assign_random_hobbies(user, count: RANDOM.rand(3..12))
  return if user.hobbies.any?

  Hobby.order(:id).to_a.sample(count, random: RANDOM).each do |hobby|
    user.user_hobbies.create!(hobby: hobby)
  end
end

def featured_events
  [
    Event.find_by!(name: "RubyConfAT 2026"),
    Event.find_by!(name: "RubyConf 2026"),
  ]
end

def user_names(count)
  # Pre-generate upfront so Faker stays deterministic across re-seeds
  Array.new(count) { Faker::Name.unique.name }
end

def seed_users
  events = featured_events.cycle

  user_names(SEED_USER_COUNT).each do |name|
    user = seed_user(name: name)
    attend_event(user, events.next)
    assign_random_hobbies(user)
  end
end

puts "Seeding #{SEED_USER_COUNT} users..."
seed_users
puts "✓ Seeded #{User.where(provider: "seed").count} demo user(s)"

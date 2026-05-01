# frozen_string_literal: true

module HobbiesHelper
  # Keep the literal class names so Tailwind's scanner picks them up.
  PILL_HOVER_CLASSES = [
    "hover:bg-party-lavender",
    "hover:bg-party-green",
    "hover:bg-party-red",
    "hover:bg-party-cyan",
  ].freeze

  # Random per render — each reload shuffles pill hover colors.
  def hobby_pill_hover_class(_hobby)
    PILL_HOVER_CLASSES.sample
  end
end

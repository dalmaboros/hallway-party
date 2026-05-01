# frozen_string_literal: true

module HobbiesHelper
  # Keep the literal class names so Tailwind's scanner picks them up.
  PILL_COLOR_THEMES = [
    { hover: "hover:bg-party-lavender", border: "border-party-lavender", soft: "bg-party-lavender-soft" },
    { hover: "hover:bg-party-green",    border: "border-party-green",    soft: "bg-party-green-soft" },
    { hover: "hover:bg-party-red",      border: "border-party-red",      soft: "bg-party-red-soft" },
    { hover: "hover:bg-party-cyan",     border: "border-party-cyan",     soft: "bg-party-cyan-soft" },
  ].freeze

  # Random per render — each reload shuffles pill hover colors.
  def hobby_pill_theme(_hobby)
    PILL_COLOR_THEMES.sample
  end
end

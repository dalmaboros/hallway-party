# frozen_string_literal: true

class HobbyPresenter
  # Keep the literal class names so Tailwind's scanner picks them up.
  PILL_COLOR_THEMES = [
    { hover: "hover:bg-party-lavender", border: "border-party-lavender", soft: "bg-party-lavender-soft" },
    { hover: "hover:bg-party-green",    border: "border-party-green",    soft: "bg-party-green-soft" },
    { hover: "hover:bg-party-red",      border: "border-party-red",      soft: "bg-party-red-soft" },
    { hover: "hover:bg-party-cyan",     border: "border-party-cyan",     soft: "bg-party-cyan-soft" },
  ].freeze

  PILL_BASE_CLASSES = "inline-block rounded-full px-3 py-1 text-sm transition hover:text-white hover:border-transparent"

  attr_reader :hobby

  delegate :to_param, to: :hobby

  def initialize(hobby)
    @hobby = hobby
  end

  def name
    hobby.name&.downcase
  end

  # Random per render — each reload shuffles pill hover colors.
  def pill_classes(shared: false)
    theme = PILL_COLOR_THEMES.sample
    variant = shared ? "#{theme[:soft]} border-2 #{theme[:border]}" : "bg-gray-100 border border-gray-200"
    "#{PILL_BASE_CLASSES} #{theme[:hover]} #{variant}"
  end

  def shared_with?(user)
    user.has_hobby?(hobby)
  end
end

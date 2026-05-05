# frozen_string_literal: true

module ApplicationHelper
  AVATAR_SIZES = {
    lg: { box: "w-20 h-20", text: "text-2xl" },
    md: { box: "w-12 h-12", text: "text-base" },
    sm: { box: "w-8 h-8", text: "text-xs" },
  }.freeze

  def avatar_size_classes(size)
    AVATAR_SIZES.fetch(size)
  end
end

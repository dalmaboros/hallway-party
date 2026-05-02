# frozen_string_literal: true

class VersionController < ApplicationController
  skip_before_action :require_sign_in!
  skip_before_action :require_event_attendance!
  skip_before_action :require_hobbies!

  REPO_URL = "https://github.com/dalmaboros/hallway-party"

  def show
    @sha = read_meta("REVISION")
    @short_sha = @sha&.first(7)
    @commit_url = @sha && "#{REPO_URL}/commit/#{@sha}"
    @build_time = read_meta("BUILD_TIME")
  end

  private

  def read_meta(filename)
    path = Rails.root.join(filename)
    return nil unless File.exist?(path)

    File.read(path).strip.presence
  end
end

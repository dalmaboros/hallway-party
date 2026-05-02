# frozen_string_literal: true

class VersionController < ApplicationController
  skip_before_action :require_sign_in!
  skip_before_action :require_event_attendance!
  skip_before_action :require_hobbies!

  REPO_URL = "https://github.com/dalmaboros/hallway-party"

  def show
    @sha = ENV["GIT_SHA"].presence
    @short_sha = @sha&.first(7)
    @commit_url = @sha && "#{REPO_URL}/commit/#{@sha}"
    @build_time = ENV["BUILD_TIME"].presence
  end
end

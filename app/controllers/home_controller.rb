# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :require_sign_in!
  skip_before_action :require_event_attendance!

  def index; end
end

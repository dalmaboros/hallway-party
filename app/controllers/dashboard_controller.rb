# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @hobbies = current_user.hobbies.order(:name)
  end
end

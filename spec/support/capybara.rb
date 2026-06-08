# frozen_string_literal: true

require "capybara/rspec"

RSpec.configure do |config|
  config.before(:each, type: :system) { driven_by :rack_test }
end

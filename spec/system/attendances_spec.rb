# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attending an event from its show page" do
  let(:user) { create(:user) }
  let(:event) { create(:event, :upcoming, name: "Showpage Conf") }

  before do
    create(:user_hobby, user:)
    create(:event_attendance, user:, event: create(:event, :past))
    stub_github_auth(uid: user.uid)
    visit "/auth/github/callback"
  end

  after { clear_github_auth }

  it "lets a non-attendee attend, revealing the attendees section", :aggregate_failures do
    visit event_path(event)
    expect(page).to have_content("only if you are attending")
    click_button "I am attending!"
    expect(page).to have_content("You're attending Showpage Conf")
    expect(page).to have_no_content("only if you are attending")
  end

  it "lets an attendee cancel, hiding the attendees section again", :aggregate_failures do
    create(:event_attendance, user:, event:)
    visit event_path(event)
    click_button "Cancel attendance"
    expect(page).to have_content("You're no longer attending Showpage Conf")
    expect(page).to have_content("only if you are attending")
  end
end

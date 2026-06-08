# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attending events from the index" do
  let(:user) { create(:user) }

  before do
    create(:user_hobby, user:)
    create(:event_attendance, user:, event: create(:event, :past))
    stub_github_auth(uid: user.uid)
    visit "/auth/github/callback"
  end

  after { clear_github_auth }

  context "with an upcoming event the user is not attending" do
    before do
      create(:event, name: "Blastoff Rails", starts_at: 3.months.from_now, ends_at: 3.months.from_now + 2.days)
    end

    it "attends then cancels via the index toggle", :aggregate_failures do
      visit events_path
      within("#upcoming-events") { click_button "Attend" }
      expect(page).to have_content("You're attending Blastoff Rails")

      within("#upcoming-events") { click_button "Cancel" }
      expect(page).to have_content("You're no longer attending Blastoff Rails")
    end
  end

  context "with an upcoming event overlapping one already attended" do
    let(:already_going) do
      create(:event, name: "Already Going", starts_at: 2.months.from_now, ends_at: 2.months.from_now + 2.days)
    end

    before do
      create(:event_attendance, user:, event: already_going)
      create(:event, name: "Clashes", starts_at: 2.months.from_now, ends_at: 2.months.from_now + 2.days)
    end

    it "blocks attending the clashing event" do
      visit events_path
      within("#upcoming-events") { click_button "Attend" }
      expect(page).to have_content("overlaps")
    end
  end
end

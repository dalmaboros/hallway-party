# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Events" do
  let(:user) { create(:user) }

  before do
    create(:user_hobby, user:)
    create(:event_attendance, user:, event: create(:event, :past))
    stub_github_auth(uid: user.uid)
    visit "/auth/github/callback"
  end

  after { clear_github_auth }

  describe "browsing the events index" do
    context "with upcoming events" do
      before do
        create(:event, name: "Sooner Conf", starts_at: 1.month.from_now, ends_at: 1.month.from_now + 2.days)
        create(:event, name: "Later Conf", starts_at: 3.months.from_now, ends_at: 3.months.from_now + 2.days)
      end

      it "lists them soonest first" do
        visit events_path

        within("#upcoming-events") do
          expect(page.text.index("Sooner Conf")).to be < page.text.index("Later Conf")
        end
      end
    end

    context "with past events" do
      before do
        create(:event, name: "Older Past Conf", starts_at: 6.months.ago, ends_at: 6.months.ago + 2.days)
        create(:event, name: "Recent Past Conf", starts_at: 1.month.ago, ends_at: 1.month.ago + 2.days)
      end

      it "lists them most recent first" do
        visit events_path

        within("#past-events") do
          expect(page.text.index("Recent Past Conf")).to be < page.text.index("Older Past Conf")
        end
      end
    end
  end

  describe "viewing an event the user attends" do
    let(:event) { create(:event, :upcoming) }

    before { create(:event_attendance, user:, event:) }

    it "shows the attendees section" do
      visit event_path(event)

      expect(page).to have_content("Attendees")
    end
  end

  describe "viewing an event the user does not attend" do
    let(:event) { create(:event, :upcoming, name: "RubyConfAT 2026", location: "Vienna, Austria") }

    it "shows details and the gated attendees message", :aggregate_failures do
      visit event_path(event)

      expect(page).to have_content("RubyConfAT 2026")
      expect(page).to have_content("Vienna, Austria")
      expect(page).to have_content("Attendees")
      expect(page).to have_content("You can see the conference attendees only if you are attending as well!")
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Events" do
  let(:user) { create(:user) }
  let!(:attended_event) do
    create(
      :event,
      name: "RubyConf 2026",
      location: "Las Vegas, NV",
      website: "https://rubyconf.example",
      time_zone: "America/Los_Angeles",
      starts_at: Time.zone.parse("2026-07-14 09:00"),
      ends_at: Time.zone.parse("2026-07-16 18:00"),
    )
  end
  let!(:other_event) do
    create(
      :event,
      :upcoming,
      name: "RubyConfAT 2026",
      location: "Vienna, Austria",
    )
  end

  before do
    create(:event_attendance, user: user, event: attended_event)
    create(:user_hobby, user: user)
    stub_github_auth(uid: user.uid)
    get "/auth/github/callback"
    follow_redirect! # land on /dashboard
  end

  after { clear_github_auth }

  describe "GET /events" do
    it "returns 200" do
      get events_path
      expect(response).to have_http_status(:ok)
    end

    it "lists active events sorted by start date" do
      get events_path
      expect(response.body.index("RubyConf 2026")).to be > response.body.index("RubyConfAT 2026")
    end

    it "marks events the viewer is attending" do
      get events_path
      attending_section = response.body[%r{RubyConf 2026.*?</li>}m]
      expect(attending_section).to include("Attending")
    end

    it "does not mark events the viewer is not attending" do
      get events_path
      non_attending_section = response.body[%r{RubyConfAT 2026.*?</li>}m]
      expect(non_attending_section).not_to include("Attending")
    end

    it "excludes past events" do
      create(:event, :past, name: "Old Conf")
      get events_path
      expect(response.body).not_to include("Old Conf")
    end
  end

  describe "GET /events/:id" do
    it "returns 200" do
      get event_path(attended_event)
      expect(response).to have_http_status(:ok)
    end

    it "renders event details" do
      get event_path(attended_event)
      expect(response.body)
        .to include("RubyConf 2026", "Las Vegas, NV", "https://rubyconf.example")
    end

    it "renders the date range" do
      get event_path(attended_event)
      expect(response.body).to include("July 14–16, 2026")
    end

    it "renders the attendees section when the viewer is attending" do
      other = create(:user, name: "Blair Other")
      create(:event_attendance, user: other, event: attended_event)
      create(:user_hobby, user: other, hobby: create(:hobby, name: "hiking"))

      get event_path(attended_event)
      expect(response.body).to include("People here", "Blair Other", "hiking")
    end

    it "does not list the current user in the attendees section" do
      get event_path(attended_event)
      expect(response.body).not_to include(user.name)
    end

    it "shows the empty attendees state when no other attendees exist" do
      get event_path(attended_event)
      expect(response.body).to include("People here", "You're early")
    end

    it "hides the attendees section when the viewer is not attending" do
      create(:user_hobby, user: create(:user, name: "Hidden Person"), hobby: create(:hobby, name: "hiking"))
      get event_path(other_event)
      expect(response.body).not_to include("People here", "Hidden Person")
    end

    it "still renders details for events the viewer is not attending" do
      get event_path(other_event)
      expect(response.body).to include("RubyConfAT 2026", "Vienna, Austria")
    end

    it "404s for an unknown event id" do
      get event_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end
end

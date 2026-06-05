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

    it "marks an upcoming event the viewer attends in the present tense" do
      get events_path
      attending_section = CGI.unescapeHTML(response.body[%r{RubyConf 2026.*?</li>}m])
      expect(attending_section).to include("You're attending")
    end

    it "does not mark events the viewer does not attend" do
      get events_path
      non_attending_section = CGI.unescapeHTML(response.body[%r{RubyConfAT 2026.*?</li>}m])
      expect(non_attending_section).not_to include("attending")
    end

    it "marks a past event the viewer attended in the past tense", :aggregate_failures do
      create(:event_attendance, user: user, event: create(:event, :past, name: "Gone Conf"))
      get events_path
      past_section = response.body[%r{Gone Conf.*?</li>}m]
      expect(past_section).to include("You attended")
      expect(past_section).not_to include("attending")
    end

    it "shows past events in a Past section, most recent first", :aggregate_failures do
      create(:event, name: "Older Past", starts_at: 6.months.ago, ends_at: 6.months.ago + 2.days)
      create(:event, name: "Recent Past", starts_at: 1.month.ago, ends_at: 1.month.ago + 2.days)
      get events_path
      expect(response.body).to include("past-events")
      expect(response.body.index("Recent Past")).to be < response.body.index("Older Past")
    end

    it "stacks the upcoming section above the past section", :aggregate_failures do
      create(:event, :past, name: "Bygone Conf")
      get events_path
      expect(response.body.index("upcoming-events")).to be < response.body.index("past-events")
      expect(response.body.index("RubyConf 2026")).to be < response.body.index("Bygone Conf")
    end

    it "omits the Past section when there are no past events" do
      get events_path
      expect(response.body).not_to include("past-events")
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

    it "marks an upcoming event the viewer attends in the present tense" do
      get event_path(attended_event)
      header = CGI.unescapeHTML(response.body[%r{<header.*?</header>}m])
      expect(header).to include("You're attending")
    end

    it "marks a past event the viewer attended in the past tense" do
      travel_to(attended_event.ends_at + 1.day) do
        get event_path(attended_event)
        header = CGI.unescapeHTML(response.body[%r{<header.*?</header>}m])
        expect(header).to include("You attended")
      end
    end

    it "shows no attendance indicator when the viewer is not attending" do
      get event_path(other_event)
      expect(CGI.unescapeHTML(response.body)).not_to include("You're attending")
    end

    context "with another attendee who shares an embedded hobby" do
      before do
        hiking = create(:hobby, name: "hiking", embedding: Array.new(Embedder::DIMENSIONS, 0.5))
        create(:user_hobby, user: user, hobby: hiking)

        other = create(:user, name: "Blair Other")
        create(:event_attendance, user: other, event: attended_event)
        create(:user_hobby, user: other, hobby: hiking)
      end

      it "renders the attendees section ranked by hobby similarity" do
        get event_path(attended_event)
        expect(response.body).to include("Attendees", "People who share your interests", "Blair Other", "hiking")
      end
    end

    context "with an attendee who shares no interests" do
      before do
        stranger = create(:user, name: "Casey Stranger")
        create(:event_attendance, user: stranger, event: attended_event)
        create(:user_hobby, user: stranger, hobby: create(:hobby, name: "spelunking"))
      end

      it "lists them under the everyone-else section" do
        get event_path(attended_event)
        expect(response.body).to include("Everyone else", "Casey Stranger")
      end
    end

    it "does not list the current user in the attendees section" do
      get event_path(attended_event)
      expect(response.body).not_to include(user.name)
    end

    it "shows the empty attendees state when no other attendees exist" do
      get event_path(attended_event)
      expect(response.body).to include("Attendees", "You're early")
    end

    it "hides the attendees section when the viewer is not attending" do
      create(:user_hobby, user: create(:user, name: "Hidden Person"), hobby: create(:hobby, name: "hiking"))
      get event_path(other_event)
      expect(response.body).not_to include("Attendees", "Hidden Person")
    end

    it "still renders details for events the viewer is not attending" do
      get event_path(other_event)
      expect(response.body).to include("RubyConfAT 2026", "Vienna, Austria")
    end

    context "when the event is in progress" do
      let!(:in_progress_event) { create(:event, :in_progress) }

      before { create(:event_attendance, user: user, event: in_progress_event) }

      it "uses the present-tense 'People here' attendees heading" do
        get event_path(in_progress_event)
        expect(response.body).to include("People here")
      end

      it "shows the Day X of Y pill, not the countdown pill" do
        get event_path(in_progress_event)
        aggregate_failures do
          expect(response.body).to match(/Day \d+ of \d+/)
          expect(response.body).not_to match(/Starts in \d+ days?/)
        end
      end
    end

    it "shows a 'Starts in N days' pill on upcoming events" do
      get event_path(attended_event)
      expect(response.body).to match(/Starts in \d+ days?/)
    end

    it "404s for an unknown event id" do
      get event_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attendees" do
  let(:user) { create(:user) }
  let!(:event) { create(:event, :upcoming) }

  before do
    create(:event_attendance, user: user, event: event)
    create(:user_hobby, user: user)
    stub_github_auth(uid: user.uid)
    get "/auth/github/callback"
    follow_redirect! # land on /dashboard so the welcome flash doesn't leak into later assertions
  end

  after { clear_github_auth }

  describe "GET /events/:event_id/attendees" do
    context "when the user is attending the event" do
      it "returns 200" do
        get event_attendees_path(event)
        expect(response).to have_http_status(:ok)
      end

      it "shows the event name in the heading" do
        get event_attendees_path(event)
        expect(response.body).to include(event.name)
      end

      it "lists other attendees" do
        other = create(:user, name: "Blair Other")
        create(:event_attendance, user: other, event: event)
        create(:user_hobby, user: other, hobby: create(:hobby, name: "hiking"))

        get event_attendees_path(event)
        expect(response.body).to include("Blair Other").and include("hiking")
      end

      it "does not list the current user" do
        get event_attendees_path(event)
        expect(response.body).not_to include(user.name)
      end

      it "shows the empty state when no other attendees exist" do
        get event_attendees_path(event)
        expect(response.body).to include("You're early")
      end
    end

    context "when the user is not attending the event" do
      let(:other_event) { create(:event, :upcoming, name: "Different Conf") }

      it "redirects to the dashboard" do
        get event_attendees_path(other_event)
        expect(response).to redirect_to(dashboard_path)
      end

      it "flashes an alert" do
        get event_attendees_path(other_event)
        expect(flash[:alert]).to include("not attending")
      end
    end
  end
end

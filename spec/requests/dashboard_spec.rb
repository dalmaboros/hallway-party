# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard" do
  let(:user) { create(:user) }
  let(:knitting) { create(:hobby, name: "knitting") }

  before do
    create(:user_hobby, user: user, hobby: knitting)
    stub_github_auth(uid: user.uid)
    get "/auth/github/callback"
  end

  after { clear_github_auth }

  describe "GET /dashboard" do
    context "with an upcoming event" do
      let!(:featured) { create(:event, :upcoming, name: "RubyConf AT") }

      before { create(:event_attendance, user: user, event: featured) }

      it "returns 200" do
        get dashboard_path
        expect(response).to have_http_status(:ok)
      end

      it "shows the user's name" do
        get dashboard_path
        expect(response.body).to include(user.name)
      end

      it "shows the user's username" do
        get dashboard_path
        expect(response.body).to include(user.username)
      end

      it "links to the user's profile" do
        get dashboard_path
        aggregate_failures do
          expect(response.body).to include("View profile")
          expect(response.body).to include(profile_path(user.username))
        end
      end

      it "shows the upcoming-event callout with the event name" do
        get dashboard_path
        aggregate_failures do
          expect(response.body).to include("You're attending")
          expect(response.body).to include("RubyConf AT")
        end
      end

      it "shows a day-count in the upcoming-event callout" do
        get dashboard_path
        expect(response.body).to match(/in \d+ days?/)
      end

      it "lists the user's upcoming events" do
        get dashboard_path
        aggregate_failures do
          expect(response.body).to include("Your Events")
          expect(response.body).to include("RubyConf AT")
        end
      end

      it "lists the user's hobbies" do
        get dashboard_path
        expect(response.body).to include("knitting")
      end

      it "sorts hobbies alphabetically" do
        create(:user_hobby, user: user, hobby: create(:hobby, name: "aardvark"))
        create(:user_hobby, user: user, hobby: create(:hobby, name: "zebra"))

        get dashboard_path
        expect(response.body.index("aardvark")).to be < response.body.index("zebra")
      end

      it "omits hobbies belonging to other users" do
        other_user = create(:user)
        create(:user_hobby, user: other_user, hobby: create(:hobby, name: "karate"))

        get dashboard_path
        expect(response.body).not_to include("karate")
      end
    end

    context "with an in-progress event" do
      let!(:in_progress) { create(:event, :in_progress, name: "RubyConf AT") }

      before { create(:event_attendance, user: user, event: in_progress) }

      it "shows the day-of-conference callout", :aggregate_failures do
        get dashboard_path
        expect(response.body).to include("You're at")
        expect(response.body).to include("RubyConf AT")
        expect(response.body).to match(/Day \d+ of \d+/)
      end

      it "hides the upcoming-countdown copy" do
        get dashboard_path
        expect(response.body).not_to match(/in \d+ days?/)
      end
    end

    context "with only past attendance" do
      let!(:past_event) { create(:event, :past) }

      before { create(:event_attendance, user: user, event: past_event) }

      it "shows the empty-state callout with a re-engagement CTA" do
        get dashboard_path
        aggregate_failures do
          expect(response.body).to include("No events on your calendar")
          expect(response.body).to include(events_path)
        end
      end

      it "hides the Your Events section" do
        get dashboard_path
        expect(response.body).not_to include("Your Events")
      end
    end
  end
end

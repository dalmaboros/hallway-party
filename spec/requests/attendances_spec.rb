# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attendances" do
  let(:user) { create(:user) }
  let!(:attended_event) do
    create(:event, starts_at: 1.month.from_now, ends_at: 1.month.from_now + 2.days)
  end
  let!(:event) do
    create(:event, starts_at: 3.months.from_now, ends_at: 3.months.from_now + 2.days)
  end

  before do
    create(:user_hobby, user:)
    create(:event_attendance, user:, event: attended_event)
    stub_github_auth(uid: user.uid)
    get "/auth/github/callback"
    follow_redirect!
  end

  after { clear_github_auth }

  describe "POST /events/:event_id/attendance" do
    it "marks the user attending and redirects to the events index", :aggregate_failures do
      expect { post event_attendance_path(event) }.to change(EventAttendance, :count).by(1)
      expect(user.event_attendances.exists?(event:)).to be(true)
      expect(response).to redirect_to(events_path)
    end

    context "when the event overlaps one the user already attends" do
      let!(:overlapping_event) do
        create(:event, starts_at: attended_event.starts_at, ends_at: attended_event.ends_at)
      end

      it "does not create an attendance and surfaces the conflict", :aggregate_failures do
        expect { post event_attendance_path(overlapping_event) }.not_to change(EventAttendance, :count)
        expect(response).to redirect_to(events_path)
        follow_redirect!
        expect(response.body).to include("overlaps")
      end
    end
  end

  describe "DELETE /events/:event_id/attendance" do
    context "when attending the event" do
      before { create(:event_attendance, user:, event:) }

      it "removes the attendance and redirects to the events index", :aggregate_failures do
        expect { delete event_attendance_path(event) }.to change(EventAttendance, :count).by(-1)
        expect(user.event_attendances.exists?(event:)).to be(false)
        expect(response).to redirect_to(events_path)
      end
    end

    context "when not attending the event" do
      it "redirects without error" do
        delete event_attendance_path(event)
        expect(response).to redirect_to(events_path)
      end
    end
  end
end

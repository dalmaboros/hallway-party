# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Onboarding" do
  let(:user) { create(:user) }

  before do
    stub_github_auth(uid: user.uid)
    get "/auth/github/callback" # sign in
  end

  after { clear_github_auth }

  describe "GET /onboarding" do
    context "when a featured event exists" do
      let!(:featured) { create(:event, :upcoming) }

      it "renders the question with the event name" do
        get onboarding_path
        expect(response.body).to include(featured.name)
      end
    end

    context "when no featured event exists" do
      it "renders the no-events state" do
        get onboarding_path
        expect(response.body).to include("No upcoming events")
      end
    end

    context "when the user already has an active attendance" do
      let!(:featured) { create(:event, :upcoming) }

      before { create(:event_attendance, user: user, event: featured) }

      it "still renders (user can revisit onboarding)" do
        get onboarding_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /onboarding/hobbies" do
    let!(:featured) { create(:event, :upcoming) }

    before { create(:event_attendance, user: user, event: featured) }

    it "renders the hobby setup page" do
      get onboarding_hobbies_path
      expect(response).to have_http_status(:ok)
    end

    it "shows the user's current hobbies" do
      hobby = create(:hobby, name: "knitting")
      create(:user_hobby, user: user, hobby: hobby)

      get onboarding_hobbies_path
      expect(response.body).to include("knitting")
    end
  end

  describe "POST /onboarding with answer: 'yes'" do
    let!(:featured) { create(:event, :upcoming) }

    it "creates an EventAttendance" do
      expect do
        post onboarding_path, params: { answer: "yes" }
      end.to change(EventAttendance, :count).by(1)
    end

    it "redirects to the hobbies onboarding step" do
      post onboarding_path, params: { answer: "yes" }
      expect(response).to redirect_to(onboarding_hobbies_path)
    end

    it "sets a welcome flash" do
      post onboarding_path, params: { answer: "yes" }
      expect(flash[:notice]).to include(featured.name)
    end
  end

  describe "POST /onboarding with answer: 'no'" do
    before do
      create(:event, :upcoming)
    end

    it "does not create an EventAttendance" do
      expect do
        post onboarding_path, params: { answer: "no" }
      end.not_to change(EventAttendance, :count)
    end

    it "keeps the user signed in" do
      post onboarding_path, params: { answer: "no" }
      expect(session[:user_id]).to eq(user.id)
    end

    it "redirects to the declined page" do
      post onboarding_path, params: { answer: "no" }
      expect(response).to redirect_to(onboarding_declined_path)
    end
  end

  describe "GET /onboarding/declined" do
    it "renders without requiring event attendance" do
      get onboarding_declined_path
      expect(response).to have_http_status(:ok)
    end

    it "offers a way back to the onboarding question for users who change their mind" do
      get onboarding_declined_path
      expect(response.body).to include(onboarding_path)
    end
  end

  describe "dashboard access gating" do
    context "when the user has no active attendance" do
      it "redirects /dashboard to /onboarding" do
        get "/dashboard"
        expect(response).to redirect_to(onboarding_path)
      end
    end

    context "when the user has an attendance but no hobbies" do
      let!(:featured) { create(:event, :upcoming) }

      before { create(:event_attendance, user: user, event: featured) }

      it "redirects /dashboard to /onboarding/hobbies" do
        get "/dashboard"
        expect(response).to redirect_to(onboarding_hobbies_path)
      end
    end

    context "when the user has an attendance and at least one hobby" do
      let!(:featured) { create(:event, :upcoming) }

      before do
        create(:event_attendance, user: user, event: featured)
        create(:user_hobby, user: user)
      end

      it "allows /dashboard" do
        get "/dashboard"
        expect(response).to have_http_status(:ok)
      end
    end
  end
end

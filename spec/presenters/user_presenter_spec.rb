# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPresenter do
  subject(:presenter) { described_class.new(user, current_user:) }

  describe "#initials" do
    let(:user) { build(:user, name: name) }
    let(:current_user) { nil }

    context "with a two-name user" do
      let(:name) { "Mona Octocat" }

      it "returns first+last capitalized initials" do
        expect(presenter.initials).to eq("MO")
      end
    end

    context "with a one-name user" do
      let(:name) { "Mona" }

      it "returns the single capitalized initial" do
        expect(presenter.initials).to eq("M")
      end
    end

    context "with three or more name parts" do
      let(:name) { "Jose Maria Octocat" }

      it "returns first+last initials" do
        expect(presenter.initials).to eq("JO")
      end
    end

    context "with a blank name" do
      let(:name) { "" }

      it "returns an empty string" do
        expect(presenter.initials).to eq("")
      end
    end

    context "with a lowercase name" do
      let(:name) { "mona octocat" }

      it "uppercases the initials" do
        expect(presenter.initials).to eq("MO")
      end
    end
  end

  describe "#website" do
    let(:user) { build(:user, website: stored_website) }
    let(:current_user) { nil }

    context "with an https URL" do
      let(:stored_website) { "https://example.com" }

      it "returns it" do
        expect(presenter.website).to eq("https://example.com")
      end
    end

    context "with a javascript: URL" do
      let(:stored_website) { "javascript:alert(1)" }

      it "returns nil to prevent XSS" do
        expect(presenter.website).to be_nil
      end
    end

    context "with a blank website" do
      let(:stored_website) { "" }

      it "returns nil" do
        expect(presenter.website).to be_nil
      end
    end
  end

  describe "#avatar_color_class" do
    let(:user) { build(:user, username: "user") }
    let(:current_user) { nil }

    it "returns one of the AVATAR_BG_CLASSES" do
      expect(described_class::AVATAR_BG_CLASSES).to include(presenter.avatar_color_class)
    end

    it "is deterministic for the same username" do
      expect(presenter.avatar_color_class).to eq(described_class.new(user).avatar_color_class)
    end
  end

  describe "#shared_hobby_presenters" do
    let(:user) { create(:user) }
    let(:current_user) { create(:user) }
    let!(:knitting) { create(:hobby, name: "knitting") }
    let!(:cycling) { create(:hobby, name: "cycling") }
    let!(:sourdough) { create(:hobby, name: "sourdough") }

    before do
      user.hobbies << [knitting, cycling, sourdough]
      current_user.hobbies << current_user_hobbies
    end

    context "when the current user shares none of the user's hobbies" do
      let(:current_user_hobbies) { [] }

      it "returns an empty array" do
        expect(presenter.shared_hobby_presenters).to eq([])
      end
    end

    context "when the current user shares a subset of the user's hobbies" do
      let(:current_user_hobbies) { [knitting, cycling] }

      it "returns just the shared ones, sorted alphabetically" do
        expect(presenter.shared_hobby_presenters.map(&:name)).to eq(["cycling", "knitting"])
      end

      it "wraps the results as HobbyPresenters" do
        expect(presenter.shared_hobby_presenters).to all(be_a(HobbyPresenter))
      end
    end

    context "when the current user shares every one of the user's hobbies" do
      let(:current_user_hobbies) { [knitting, cycling, sourdough] }

      it "returns all of them, sorted alphabetically" do
        expect(presenter.shared_hobby_presenters.map(&:name)).to eq(["cycling", "knitting", "sourdough"])
      end
    end

    context "when the current user has hobbies the user does not have" do
      let(:current_user_hobbies) { [create(:hobby, name: "rock climbing")] }

      it "ignores the unrelated hobbies" do
        expect(presenter.shared_hobby_presenters).to eq([])
      end
    end
  end

  describe "#non_shared_hobby_presenters" do
    let(:user) { create(:user) }
    let(:current_user) { create(:user) }
    let!(:knitting) { create(:hobby, name: "knitting") }
    let!(:cycling) { create(:hobby, name: "cycling") }
    let!(:sourdough) { create(:hobby, name: "sourdough") }

    before do
      user.hobbies << [knitting, cycling, sourdough]
      current_user.hobbies << current_user_hobbies
    end

    context "when the current user shares none of the user's hobbies" do
      let(:current_user_hobbies) { [] }

      it "returns all of them, sorted alphabetically" do
        expect(presenter.non_shared_hobby_presenters.map(&:name)).to eq(["cycling", "knitting", "sourdough"])
      end

      it "wraps the results as HobbyPresenters" do
        expect(presenter.non_shared_hobby_presenters).to all(be_a(HobbyPresenter))
      end
    end

    context "when the current user shares a subset of the user's hobbies" do
      let(:current_user_hobbies) { [knitting, cycling] }

      it "returns just the non-shared ones, sorted alphabetically" do
        expect(presenter.non_shared_hobby_presenters.map(&:name)).to eq(["sourdough"])
      end
    end

    context "when the current user shares every one of the user's hobbies" do
      let(:current_user_hobbies) { [knitting, cycling, sourdough] }

      it "returns an empty array" do
        expect(presenter.non_shared_hobby_presenters).to eq([])
      end
    end
  end

  describe "#not_past_events" do
    let(:user) { create(:user) }
    let(:presenter) { described_class.new(user) }

    it "returns events the user is attending whose end date hasn't passed" do
      upcoming = create(:event, :upcoming)
      in_progress = create(:event, :in_progress)
      past = create(:event, :past)
      [upcoming, in_progress, past].each { |e| create(:event_attendance, user: user, event: e) }

      expect(presenter.not_past_events).to contain_exactly(upcoming, in_progress)
    end

    it "orders by start date ascending — the soonest upcoming first" do
      farther = create(:event, starts_at: 3.months.from_now, ends_at: 3.months.from_now + 2.days)
      sooner = create(:event, starts_at: 1.week.from_now, ends_at: 1.week.from_now + 2.days)
      [farther, sooner].each { |e| create(:event_attendance, user: user, event: e) }

      expect(presenter.not_past_events).to eq([sooner, farther])
    end
  end

  describe "#past_events" do
    let(:user) { create(:user) }
    let(:presenter) { described_class.new(user) }

    it "returns events the user attended whose end date has passed" do
      upcoming = create(:event, :upcoming)
      in_progress = create(:event, :in_progress)
      past = create(:event, :past)
      [upcoming, in_progress, past].each { |e| create(:event_attendance, user: user, event: e) }

      expect(presenter.past_events).to eq([past])
    end

    it "orders by start date descending — the most-recent past event first" do
      older = create(:event, starts_at: 1.year.ago, ends_at: 1.year.ago + 2.days)
      newer = create(:event, starts_at: 2.months.ago, ends_at: 2.months.ago + 2.days)
      [older, newer].each { |e| create(:event_attendance, user: user, event: e) }

      expect(presenter.past_events).to eq([newer, older])
    end
  end
end

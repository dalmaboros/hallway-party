# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserHobbyPresenter do
  describe "delegations" do
    let(:presenter) { described_class.new(build(:user_hobby)) }
    let(:delegated_methods) { [:to_param] }

    it "delegates the listed methods to user_hobby" do
      aggregate_failures do
        delegated_methods.each do |method|
          expect(presenter).to delegate_method(method).to(:user_hobby)
        end
      end
    end
  end

  describe "#hobby_name" do
    let(:user) { create(:user) }
    let(:hobby) { create(:hobby, name: "Knitting") }
    let(:user_hobby) { create(:user_hobby, user: user, hobby: hobby) }
    let(:presenter) { described_class.new(user_hobby) }

    it "returns the underlying hobby's name lowercased" do
      expect(presenter.hobby_name).to eq("knitting")
    end
  end
end

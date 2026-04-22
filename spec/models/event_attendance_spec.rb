# frozen_string_literal: true

# == Schema Information
#
# Table name: event_attendances
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_event_attendances_on_event_id              (event_id)
#  index_event_attendances_on_user_id               (user_id)
#  index_event_attendances_on_user_id_and_event_id  (user_id,event_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe EventAttendance do
  describe "associations" do
    subject(:attendance) { build(:event_attendance) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:event) }
  end

  describe "uniqueness" do
    subject { create(:event_attendance) }

    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:event_id) }
  end

  describe "overlap validation" do
    let(:user) { create(:user) }
    let(:first_event) do
      create(
        :event,
        starts_at: Time.zone.parse("2026-07-01 09:00"),
        ends_at: Time.zone.parse("2026-07-03 18:00"),
      )
    end
    let(:attendance) { build(:event_attendance, user: user, event: second_event) }

    before { create(:event_attendance, user: user, event: first_event) }

    context "when the new event overlaps existing attendance dates" do
      let(:second_event) do
        create(
          :event,
          starts_at: Time.zone.parse("2026-07-02 09:00"),
          ends_at: Time.zone.parse("2026-07-05 18:00"),
        )
      end

      it "is rejected" do
        expect(attendance).not_to be_valid
      end
    end

    context "when the new event is fully contained within existing dates" do
      let(:second_event) do
        create(
          :event,
          starts_at: Time.zone.parse("2026-07-02 09:00"),
          ends_at: Time.zone.parse("2026-07-02 18:00"),
        )
      end

      it "is rejected" do
        expect(attendance).not_to be_valid
      end
    end

    context "when the new event starts after the existing attendance ends" do
      let(:second_event) do
        create(
          :event,
          starts_at: Time.zone.parse("2026-07-04 09:00"),
          ends_at: Time.zone.parse("2026-07-06 18:00"),
        )
      end

      it "is valid" do
        expect(attendance).to be_valid
      end
    end

    context "when the new event ends before the existing attendance starts" do
      let(:second_event) do
        create(
          :event,
          starts_at: Time.zone.parse("2026-06-20 09:00"),
          ends_at: Time.zone.parse("2026-06-25 18:00"),
        )
      end

      it "is valid" do
        expect(attendance).to be_valid
      end
    end

    context "when the new event starts exactly when the existing one ends" do
      let(:second_event) do
        create(
          :event,
          starts_at: Time.zone.parse("2026-07-03 18:00"),
          ends_at: Time.zone.parse("2026-07-05 18:00"),
        )
      end

      it "is valid" do
        expect(attendance).to be_valid
      end
    end

    context "when re-saving an existing attendance" do
      let(:existing) { user.event_attendances.first }

      it "does not flag the record itself as overlapping" do
        expect(existing).to be_valid
      end
    end
  end
end

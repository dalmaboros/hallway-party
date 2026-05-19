# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                          :bigint           not null, primary key
#  avatar_url                  :string
#  bio                         :text
#  bluesky_url                 :string
#  email                       :string
#  email_notifications_enabled :boolean          default(TRUE), not null
#  linkedin_url                :string
#  location                    :string
#  mastodon_url                :string
#  name                        :string           not null
#  pronouns                    :string
#  provider                    :string           not null
#  twitter_url                 :string
#  uid                         :string           not null
#  username                    :string           not null
#  website                     :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_users_on_email             (email) UNIQUE
#  index_users_on_provider_and_uid  (provider,uid) UNIQUE
#  index_users_on_username          (username) UNIQUE
#
class User < ApplicationRecord
  has_many :event_attendances, dependent: :destroy
  has_many :events, through: :event_attendances
  has_many :user_hobbies, dependent: :destroy
  has_many :hobbies, through: :user_hobbies

  validates :provider, :uid, :username, :name, presence: true
  validates :username, uniqueness: true
  validates :uid, uniqueness: { scope: :provider }
  validates :email,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP },
    allow_nil: true

  before_save :downcase_email

  def github_url
    "https://github.com/#{username}"
  end

  def has_hobby?(hobby)
    hobby_id_set.include?(hobby.id)
  end

  def attendee_of?(event)
    event_id_set.include?(event.id)
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def hobby_id_set
    @hobby_id_set ||= hobby_ids.to_set
  end

  def event_id_set
    @event_id_set ||= event_ids.to_set
  end
end

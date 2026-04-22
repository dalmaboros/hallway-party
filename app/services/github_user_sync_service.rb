# frozen_string_literal: true

class GithubUserSyncService
  class << self
    def call(auth_hash)
      new(auth_hash).call
    end
  end

  def initialize(auth_hash)
    @auth_hash = auth_hash
  end

  def call
    user = User.find_or_initialize_by(provider: @auth_hash.provider, uid: @auth_hash.uid)
    user.assign_attributes(attributes_from_auth_hash) if user.new_record?
    user.save!
    user
  end

  private

  def attributes_from_auth_hash
    info = @auth_hash.info
    raw_info = @auth_hash.extra&.raw_info

    {
      username: info.nickname,
      name: info.name.presence || info.nickname,
      email: info.email,
      avatar_url: info.image,
      location: raw_info&.location,
      pronouns: raw_info&.pronouns,
    }
  end
end

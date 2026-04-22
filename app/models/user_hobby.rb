# frozen_string_literal: true

# == Schema Information
#
# Table name: user_hobbies
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  hobby_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_hobbies_on_hobby_id              (hobby_id)
#  index_user_hobbies_on_hobby_id_and_user_id  (hobby_id,user_id) UNIQUE
#  index_user_hobbies_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (hobby_id => hobbies.id)
#  fk_rails_...  (user_id => users.id)
#
class UserHobby < ApplicationRecord
  belongs_to :user
  belongs_to :hobby

  validates :user_id, uniqueness: { scope: :hobby_id }

  before_destroy :ensure_user_retains_at_least_one_hobby

  private

  def ensure_user_retains_at_least_one_hobby
    return if destroyed_by_association
    return if user.user_hobbies.many?

    errors.add(:base, "You must have at least one hobby")
    throw(:abort)
  end
end

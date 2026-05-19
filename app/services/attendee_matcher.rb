# frozen_string_literal: true

class AttendeeMatcher
  TOP_N_NEIGHBORS = 10
  RESULT_LIMIT = 50
  # Cosine similarity has a floor near 0.3 even for unrelated hobbies, so a 0.5
  # threshold still admits genuinely related concepts (e.g. knitting ↔ fiber arts).
  SIMILARITY_THRESHOLD = 0.5

  def initialize(user:, event:)
    @user = user
    @event = event
  end

  def match_attendees
    return [] if ranked_user_ids.empty?

    users_by_id = User.where(id: ranked_user_ids).includes(:hobbies).index_by(&:id)
    ranked_user_ids.filter_map { |id| users_by_id[id] }
  end

  private

  def embedded_user_hobbies
    @embedded_user_hobbies ||= @user.hobbies.to_a.select { |hobby| hobby.embedding.present? }
  end

  def candidate_user_ids
    @candidate_user_ids ||= User
      .joins(:event_attendances)
      .where(event_attendances: { event_id: @event.id })
      .where.not(id: @user.id)
      .pluck(:id)
  end

  def ranked_user_ids
    @ranked_user_ids ||= rank_by_normalized_score(similarity_scores)
  end

  def similarity_scores
    scores = Hash.new(0.0)
    embedded_user_hobbies.each do |hobby|
      Hobby
        .where.not(embedding: nil)
        .nearest_neighbors(:embedding, hobby.embedding, distance: "cosine")
        .limit(TOP_N_NEIGHBORS)
        .each do |neighbor|
          similarity = 1.0 - neighbor.neighbor_distance
          next if similarity < SIMILARITY_THRESHOLD

          neighbor.user_hobbies.where(user_id: candidate_user_ids).pluck(:user_id).each do |user_id|
            scores[user_id] += similarity
          end
        end
    end
    scores
  end

  def rank_by_normalized_score(scores)
    # Normalize by sqrt(candidate's hobby count) so users with many hobbies
    # don't out-rank users with fewer, stronger overlaps just by accumulation.
    scores
      .map { |user_id, sum| [user_id, sum / Math.sqrt(candidate_hobby_counts.fetch(user_id, 1))] }
      .sort_by { |_, score| -score }
      .first(RESULT_LIMIT)
      .map(&:first)
  end

  def candidate_hobby_counts
    @candidate_hobby_counts ||= UserHobby
      .where(user_id: candidate_user_ids)
      .group(:user_id)
      .count
  end
end

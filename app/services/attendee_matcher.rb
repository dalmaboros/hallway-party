# frozen_string_literal: true

class AttendeeMatcher
  TOP_N_NEIGHBORS = 10
  RESULT_LIMIT = 50
  # Cosine similarity below this is treated as noise and not credited.
  # OpenAI text embeddings rarely drop unrelated hobbies below ~0.3, so a 0.5
  # floor still admits genuinely related concepts (e.g. knitting↔fiber arts).
  SIMILARITY_THRESHOLD = 0.5

  def initialize(seed_hobbies:, event:, exclude_user:)
    @seed_hobbies = seed_hobbies
    @event = event
    @exclude_user = exclude_user
  end

  def call
    return fallback_attendees if embedded_seeds.empty?

    ranked_ids = compute_ranked_user_ids
    return fallback_attendees if ranked_ids.empty?

    users_by_id = User.where(id: ranked_ids).includes(:hobbies).index_by(&:id)
    ranked_ids.filter_map { |id| users_by_id[id] }
  end

  private

  attr_reader :seed_hobbies, :event, :exclude_user

  def embedded_seeds
    @embedded_seeds ||= seed_hobbies.select { |hobby| hobby.embedding.present? }
  end

  def candidate_user_ids
    @candidate_user_ids ||= User
      .joins(:event_attendances)
      .where(event_attendances: { event_id: event.id })
      .where.not(id: exclude_user.id)
      .pluck(:id)
  end

  def compute_ranked_user_ids
    scores = Hash.new(0.0)

    embedded_seeds.each do |seed|
      Hobby
        .where.not(embedding: nil)
        .nearest_neighbors(:embedding, seed.embedding, distance: "cosine")
        .limit(TOP_N_NEIGHBORS)
        .each do |neighbor|
          similarity = 1.0 - neighbor.neighbor_distance
          next if similarity < SIMILARITY_THRESHOLD

          neighbor.user_hobbies.where(user_id: candidate_user_ids).pluck(:user_id).each do |user_id|
            scores[user_id] += similarity
          end
        end
    end

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

  def fallback_attendees
    User
      .joins(:event_attendances)
      .where(event_attendances: { event_id: event.id })
      .where.not(id: exclude_user.id)
      .includes(:hobbies)
      .order(:name)
      .limit(RESULT_LIMIT)
      .to_a
  end
end

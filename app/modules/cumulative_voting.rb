# According to https://docs.google.com/document/d/1m5W76bIrW805jMka2jy5i489oJEzr-DbHRUpI3Ahm7w/edit
# we make the following assumptions:
# * The range of each scores is 1-9 (inclusive)
# * Abstaining is allowed
# According to https://en.wikipedia.org/wiki/Range_voting
# If voters are allowed to abstain, then the average of the scores is used to
# calculate score instead of the sum. This module does not take into account sum
# of scores, truncated mean or Majority Judgment.
module CumulativeVoting
  # This calculates the score for a candidate, defined as the average of non-abstained values.
  def self.calculate_score(scores)
    return nil if scores.count == 0
    sum = scores.inject(0) {|sum, score| sum + score.to_f}
    return sum
  end
  
  def self.identify_candidate(candidate_id)
     candidate = Candidate.find_by_id(candidate_id)
     return candidate.candidate_uuid
  end
   # This method sorts the candidates from highest to lowest score.
  def self.sort_candidates_by_score(votes)
    candidate_votes = []
    votes.each do |vote|
      next if vote.value.blank?

      matching_candidate = candidate_votes.find {|cv| cv[:candidate_id] == vote.candidate_id}      
      matching_candidate_uuid = CumulativeVoting.identify_candidate(vote.candidate_id)
      if matching_candidate.blank?
        candidate_votes << {:candidate_id => vote.candidate_id, :values => [vote.value], :candidate_uuid => matching_candidate_uuid}
      else
        matching_candidate[:values] << vote.value
      end
    end

    candidate_votes.each do |cv|
      cv[:score] = CumulativeVoting.calculate_score(cv[:values])
    end

    candidate_votes = candidate_votes.sort_by {|cv| cv[:score]}.reverse
    return candidate_votes
  end
end

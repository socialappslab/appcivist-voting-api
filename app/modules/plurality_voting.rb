# According to https://docs.google.com/document/d/1m5W76bIrW805jMka2jy5i489oJEzr-DbHRUpI3Ahm7w/edit
# we make the following assumptions:
# * The possible types of plurarlity are
#   - YES/NO (abstention is considered NO)
#   - YES/NO/ABSTAIN (abstention allowed)
#   - YES/NO/ABSTAIN/BLOCKED
#
# Winning Criteria
# Yes
# => The winning proposal is the one with most yes votes.
# Yes/No
# => The winning proposal is the one with the largest yes/no ratio among the proposals that meet quorum.
# TODO: Yes/No/Abstain
# => The winning proposal is the one with the largest yes/no ratio among the proposals that meet quorum. Abstain votes count for quorum.
# TODO: Yes/No/Abstain/Block
# => The winning proposal is the one with the largest yes/no ratio among the proposals that meet quorum and have less than X block votes.
 
# If blocking enabled, blocked proposals are pushed to end
module PluralityVoting
  # This calculates the sums of YES, NO, ABSTAIN and BLOCKS of the candidate
  def self.summarize_score(scores)
    return nil if scores.count == 0
    summary  = Hash.new
    summary[:yes] = scores.count {|x| x=="YES"}
    summary[:no] = scores.count {|x| x=="NO"}
    summary[:abstain] = scores.count {|x| x=="ABSTAIN"}
    summary[:block] = scores.count {|x| x=="BLOCK"}
    return summary
  end
  
  # This calculates the score for a candidate, defined as the difference between YES and NOs
  def self.calculate_score(summary)
    score = summary[:yes]-summary[:no];
    return score
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
      matching_candidate_uuid = PluralityVoting.identify_candidate(vote.candidate_id)
      if matching_candidate.blank?
        candidate_votes << {:candidate_id => vote.candidate_id, :values => [vote.value], :candidate_uuid => matching_candidate_uuid}
      else
        matching_candidate[:values] << vote.value
      end
    end

    candidate_votes.each do |cv|
      cv[:summary] = PluralityVoting.summarize_score(cv[:values])
      cv[:score] = PluralityVoting.calculate_score(cv[:summary])
    end

    candidate_votes = candidate_votes.sort_by {|cv| cv[:score]}.reverse
    return candidate_votes
  end
end

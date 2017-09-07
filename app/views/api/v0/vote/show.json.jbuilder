json.ballot do
  json.(@ballot, :uuid, :voting_system_type, :instructions, :notes, :votes_limit, :votes_limit_meaning)
  json.ballot_configurations @ballot.ballot_configurations
  json.candidates @ballot.candidates
  i = 0
  json.candidatesIndex do 
    @ballot.candidates.each { |candidate|
      json.set!(candidate.candidate_uuid,i)
      i = i + 1
    }
  end
end

json.set! :vote do
  json.(@ballot_paper, :uuid, :signature, :status)
  json.votes @ballot_paper.votes do |vote|
    json.(vote, :candidate_id, :value, :value_type)
  end
  i = 0
  json.votesIndex do 
    @ballot_paper.votes.each { |vote|
      json.set!(vote.candidate_id,i)
      i = i + 1
    }
  end
end

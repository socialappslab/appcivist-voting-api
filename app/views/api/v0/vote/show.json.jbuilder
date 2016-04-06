json.ballot do
  json.(@ballot, :uuid, :voting_system_type, :instructions, :notes)
  json.ballot_configurations @ballot.ballot_configurations
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

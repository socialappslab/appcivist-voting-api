json.ballot do
  json.(@ballot, :uuid, :voting_system_type)
end

if @ballot_paper.present?
  json.set! :vote do
    json.(@ballot_paper, :uuid, :signature, :status)
    json.votes @ballot_paper.votes do |vote|
      json.(vote, :candidate_id, :value, :value_type)
    end
  end
else
  json.set! :vote, {}
end
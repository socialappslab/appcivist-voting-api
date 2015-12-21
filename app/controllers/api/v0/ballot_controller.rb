class API::V0::BallotController < ActionController::API
  resource_description do
    api_version "v0"
    formats ["json"]
    param :ballot_uuid, String, :desc => "UUID of the ballot", :required => true
    error 404, "Ballot does not exist"
  end


  #----------------------------------------------------------------------------
  # GET /api/v0/ballot/:ballot_uuid/registration

  api! "Retrieves the VotingBallot registration form along with its fields."
  def registration_form
  end

  #----------------------------------------------------------------------------
  # GET /api/v0/ballot/:ballot_uuid/registration

  api! %Q(Verifies the values provided by the user for each field in the
  VotingBallot registration form and responds with both the password for the
  VotingBallot and a specific generated "signature" for the voter. The
  signature will be used by the voter to retrieve their personal vote.)
  example <<-EOS
    JSON: {
      "password": "...",
      "signature": "..."
    }
  EOS
  def registration
  end

  #----------------------------------------------------------------------------

end

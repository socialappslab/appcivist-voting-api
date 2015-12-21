class API::V0::BallotController < ApplicationController
  resource_description do
    api_version "v0"
    formats ["json"]
  end

  #----------------------------------------------------------------------------
  # POST /api/v0/ballot

  api! "Create the ballot"
  def create
  end

  #----------------------------------------------------------------------------
  # GET /api/v0/ballot/:ballot_uuid/registration

  api! "Retrieves the VotingBallot registration form along with its fields."
  param_group :ballot, ApplicationController
  error 404, "Ballot does not exist"
  def registration_form
  end

  #----------------------------------------------------------------------------
  # POST /api/v0/ballot/:ballot_uuid/registration

  api! %Q(Verifies the values provided by the user for each field in the
  VotingBallot registration form and responds with both the password for the
  VotingBallot and a specific generated "signature" for the voter. The
  signature will be used by the voter to retrieve their personal vote.)
  param_group :ballot, ApplicationController
  error 404, "Ballot does not exist"
  example <<-EOS
    "vote": {
      "password": "...",
      "signature": "..."
    }
  EOS
  def registration
  end

  #----------------------------------------------------------------------------

end

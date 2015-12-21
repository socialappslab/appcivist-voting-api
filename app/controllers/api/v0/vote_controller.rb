class API::V0::VoteController < ApplicationController
  resource_description do
    api_version "v0"
    formats ["json"]
    param_group :ballot, ApplicationController
  end

  def_param_group :vote_with_signature do
    param :signature, String, :desc => "Signature corresponding to the voter", :required => true
    error 404, "Vote does not exist"
    error 404, "Ballot does not exist"
  end

  #----------------------------------------------------------------------------
  # POST /api/v0/ballot/:ballot_uuid/vote

  api! %Q(Creates a VotingBallot with the signature provided by the user)
  param_group :vote_with_signature
  def create
  end

  #----------------------------------------------------------------------------
  # GET /api/v0/ballot/:ballot_uuid/vote?signature=...

  api! %Q(Retrieves both the ballot identified by UUID and the corresponding vote
  for the signature (or an empty object if that vote has not been created yet))
  param_group :vote_with_signature
  example "'ballot': {'...', 'vote': {'...'}}"
  def show
  end

  #----------------------------------------------------------------------------
  # PUT /api/v0/ballot/:ballot_uuid/vote/:id

  api! %Q(Updates a VotingBallot instance)
  param :id, String, :desc => "ID of the corresponding vote", :required => true
  error 404, "Vote does not exist"
  error 404, "Ballot does not exist"
  def update
  end

  #----------------------------------------------------------------------------

end

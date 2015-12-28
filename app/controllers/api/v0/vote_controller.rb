class API::V0::VoteController < ApplicationController
  before_action :identify_ballot

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

  api! %Q(Creates a Candidate and Vote with the signature provided by the user)
  error 404, "Ballot does not exist"
  error 404, "Candidate does not exist"
  error 400, "Signature can't be blank"
  param_group :vote_with_signature
  def create
    # TODO: This controller action is not idempotent, e.g. multiple requests to
    # this endpoint WILL create multiple votes. Is this by design?
    @candidate = Candidate.find_by_uuid(params[:candidate_uuid])
    if @candidate.blank?
      render :json => {:error => "Candidate does not exist"}, :status => 404 and return
    end

    # Create a vote based on the provided signature (if at all provided)
    vote           = Vote.new
    vote.ballot    = @ballot
    vote.candidate = @candidate
    vote.signature = params[:signature]
    vote.status    = Vote::Status::DRAFT
    if vote.save
      render :json => vote.as_json(:only => [:signature, :status, :value, :value_type]), :status => 200 and return
    else
      render :json => {:error => vote.errors.full_messages[0]}, :status => 400 and return
    end
  end

  #----------------------------------------------------------------------------
  # GET /api/v0/ballot/:ballot_uuid/vote?signature=...

  api! %Q(Retrieves both the ballot identified by UUID and the corresponding vote
  for the signature (or an empty object if that vote has not been created yet))
  param_group :vote_with_signature
  example "Response: { 'ballot': {'...'}, 'vote': {'...'} }"
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

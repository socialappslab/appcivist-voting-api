class API::V0::VoteController < ApplicationController
  before_action :identify_ballot

  resource_description do
    api_version "v0"
    formats ["json"]
    param_group :ballot, ApplicationController
  end

  def_param_group :vote_with_signature do
    param :signature, String, :desc => "Signature corresponding to the voter", :required => true
  end

  #----------------------------------------------------------------------------
  # POST /api/v0/ballot/:ballot_uuid/vote

  api! %Q(Creates a Candidate and Vote with the signature provided by the user)
  error 404, "Ballot does not exist"
  error 404, "Candidate does not exist"
  error 400, "Signature can't be blank"
  param :candidate_uuid, String, :desc => "UUID of the candidate being voted on", :required => true
  param_group :vote_with_signature
  example <<-EOS
    Sample request: {candidate_uuid: b8da40901dbee9cd067057516a6470b64eebd348, signature: 234asfasdf8234}
    Sample response: {
      signature: 234asfasdf8234,
      status: "DRAFT",
      value: "...",
      value_type: "..."
    }
  EOS
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
  # GET /api/v0/ballot/:ballot_uuid/vote/:signature

  api! %Q(Retrieves both the ballot identified by UUID and the corresponding vote
  for the signature (or an empty object if that vote has not been created yet))
  param_group :vote_with_signature
  error 404, "Ballot does not exist"
  example <<-EOS
    Sample request: /api/v0/ballot/23afdsf-234234ihfv0dfa/vote/234asfasdf8234
    Sample response: {
      ballot: {
        uuid: 23afdsf-234234ihfv0dfa,
        voting_system_type: 1
      },
      vote: {
        signature: 234asfasdf8234,
        status: "DRAFT",
        value: "...",
        value_type: "..."
      }
    }
  EOS
  def show
    @vote = @ballot.votes.find_by_signature(params[:signature])
    if @vote.blank?
      render :json => {:ballot => @ballot.as_json(:only => [:uuid, :voting_system_type]) , :vote => {}}
    else
      render :json => {:ballot => @ballot.as_json(:only => [:uuid, :voting_system_type]) , :vote => @vote.as_json(:only => [:signature, :status, :value, :value_type])}
    end
  end

  #----------------------------------------------------------------------------
  # PUT /api/v0/ballot/:ballot_uuid/vote/:signature

  api! %Q(Updates a Vote instance)
  param_group :vote_with_signature
  error 404, "Ballot does not exist"
  error 404, "Vote does not exist"
  def update
  end

  #----------------------------------------------------------------------------

end

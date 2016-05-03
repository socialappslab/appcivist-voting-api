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

  api! %Q(Creates a BallotPaper instance with the signature provided by the user)
  error 404, "Ballot does not exist"
  error 400, "Signature can't be blank"
  # See https://github.com/docker/docker-registry/issues/10
  # on why we're using error code 409
  error 409, "Ballot with that signature already exists"
  param :vote, Hash, :required => true, :desc => "Vote hash containing the value" do
    param :signature, String, :desc => "Signature corresponding to the voter", :required => true
  end
  example <<-EOS
    Sample request: {
      vote: {
        signature: b8da40901dbee9cd067057516a6470b64eebd348
      }
    }
    Sample response: {
      vote : {
        uuid: ...,
        signature: b8da40901dbee9cd067057516a6470b64eebd348,
        status: 0
      }
    }
  EOS
  def create
    ballot_paper = BallotPaper.find_by_signature_and_ballot_id(ballot_paper_params[:signature], @ballot.id)
    if ballot_paper.present?
      render :json => {:error => "Ballot with that signature already exists"}, :status => 409 and return
    end

    # Create a ballot paper based on the provided signature.
    puts @ballot.id
    
    ballot_paper           = BallotPaper.new
    ballot_paper.ballot    = @ballot
    ballot_paper.signature = ballot_paper_params[:signature]
    ballot_paper.status    = BallotPaper::Status::DRAFT
    if ballot_paper.save
      render :json => {:vote => ballot_paper.as_json(:only => [:uuid, :signature, :status])}, :status => 200 and return
    else
      render :json => {:error => ballot_paper.errors.full_messages[0]}, :status => 400 and return
    end
  end

  #----------------------------------------------------------------------------
  # GET /api/v0/ballot/:ballot_uuid/vote/:signature

  api! %Q(Retrieves both the ballot identified by UUID and all candidate votes associated
  with the signature)
  param_group :vote_with_signature
  error 404, "Ballot does not exist"
  error 404, "There are no votes under this signature."
  example <<-EOS
    Sample request: /api/v0/ballot/52b59fbd-4b93-4227-b974-e1ba4a8c678d/vote/b8da40901dbee9cd067057516a6470b64eebd348
    Sample response: {
      ballot: {
        uuid: 52b59fbd-4b93-4227-b974-e1ba4a8c678d,
        voting_system_type: 'range',
        instructions: '...',
        notes: '...',
        ballot_configurations: [
          {key: 'minimum', value: 0},
          {key: 'maximum', value: 100}
        ]
      },
      vote: {
        uuid: ...,
        signature: b8da40901dbee9cd067057516a6470b64eebd348,
        status: 0,
        votes: [
          {candidate_id: ..., value: "...", value_type: "..."},
          {candidate_id: ..., value: "...", value_type: "..."},
          ...
        ]
      }
    }
  EOS
  def show
    if params[:signature].blank?
      render :json => {:error => "You need to enter your signature!"}, :status => 400 and return
    end

    @ballot_paper = @ballot.ballot_papers.find_by_signature_and_ballot_id(params[:signature], @ballot.id)
    if @ballot_paper.blank?
      render :json => {:error => "There are no votes under this signature."}, :status => 400 and return
    end
  end

  #----------------------------------------------------------------------------
  # PUT /api/v0/ballot/:ballot_uuid/vote/:signature

  api! %Q(Updates a BallotPaper instance)
  param_group :vote_with_signature
  param :vote, Hash, :required => true, :desc => "Vote hash containing the value" do
    param :value, String, :desc => "Value input by user"
  end
  error 404, "Ballot does not exist"
  error 404, "Ballot paper does not exist"
  error 400, "Ballot paper could not be saved"
  example <<-EOS
    Sample request: {
      vote: {
        votes: [
          {uuid: ..., user_input: "..."},
          {uuid: ..., user_input: "..."}
        ]
      }
  EOS
  def update
    @ballot_paper = @ballot.ballot_papers.find_by_signature_and_ballot_id(params[:signature], @ballot.id)
    if @ballot_paper.blank?
      render :json => {:error => "Ballot paper does not exist"}, :status => 404 and return
    end

    params[:vote][:votes].each do |v|
      if v[:candidate_id].blank?
        render :json => {:error => "Candidate ID could not be identified!"}, :status => 400 and return
      end

      vote = @ballot_paper.votes.find_by_candidate_id(v[:candidate_id])
      if vote.blank?
        vote = Vote.new(:ballot_paper_id => @ballot_paper.id, :candidate_id => v[:candidate_id])
      end

      vote.value = v[:value].presence
      vote.save
    end

    if @ballot_paper.update_attributes(ballot_paper_params)
      render :json => @ballot_paper.as_json(:root => true, :only => [:signature, :status]), :status => 200 and return
    else
      render :json => {:error => @ballot_paper.errors.full_messages[0]}, :status => 400 and return
    end
  end

  #----------------------------------------------------------------------------
  # PUT /api/v0/ballot/:ballot_uuid/vote/:signature/complete

  api! %Q(Changes the status of a BallotPaper instance to FINISHED)
  param_group :vote_with_signature
  error 404, "Ballot does not exist"
  error 404, "Ballot paper does not exist"
  error 400, "Ballot paper could not be saved"
  def complete
    @ballot_paper = @ballot.ballot_papers.find_by_signature_and_ballot_id(params[:signature],@ballot.id)
    if @ballot_paper.blank?
      render :json => {:error => "Ballot paper does not exist"}, :status => 404 and return
    end

    @ballot_paper.status = BallotPaper::Status::FINISHED
    if @ballot_paper.update_attributes(ballot_paper_params)
      render :json => @ballot_paper.as_json(:root => true, :only => [:signature, :status]), :status => 200 and return
    else
      render :json => {:error => @ballot_paper.errors.full_messages[0]}, :status => 400 and return
    end
  end

  #----------------------------------------------------------------------------
  # PUT /api/v0/ballot/:ballot_uuid/vote/:signature/single
  # 1. Find the specific candidate in list of votes of the ballot paper
  # 2. Update vote value using the body of the request
  api! %Q(Changes the value of a specific vote in a ballot paper)
  param :vote, Hash, :required => true, :desc => "Vote hash containing the candidate id and the vote value" do
    param :candidate_id, Integer, :desc => "ID of the candidate whose vote we are updating", :required => true
    param :value, String, :desc => "Instructions for the ballot", :required => true
  end
  param_group :vote_with_signature
  error 404, "Ballot does not exist"
  error 404, "Ballot paper does not exist"
  error 404, "Candidate does not exist"
  error 400, "Ballot paper could not be saved"
  example <<-EOS
    Sample request:
    {
      "candidate_id": 1,
      "value": "BLOCK"
    }
  EOS
  def single
    @ballot_paper = @ballot.ballot_papers.find_by_signature_and_ballot_id(params[:signature], @ballot.id)
    if @ballot_paper.blank?
      render :json => {:error => "Ballot paper does not exist"}, :status => 404 and return
    end

    @candidate = @ballot.candidates.find_by_id(params[:candidate_id])  
    if @candidate.blank?
      render :json => {:error => "Candidate does not exist"}, :status => 404 and return
    end
    
    @vote = @ballot_paper.votes.find_by_candidate_id(params[:candidate_id])
    if @vote.blank?
      @vote = Vote.new(:ballot_paper_id => @ballot_paper.id, :candidate_id => params[:candidate_id])
      @vote.value = params[:value].presence
      @vote.save
    end
    @vote.value = params[:value].presence
      
    if @vote.save
      @ballot_paper = @ballot.ballot_papers.find_by_signature_and_ballot_id(params[:signature], @ballot.id)
      candidatesIndex = Hash.new
  
      i = 0
      for candidate in @ballot.candidates
        candidatesIndex[candidate[:contribution_uuid]] = i
        i += 1
      end    

      render :json => {
        :ballot => {
          :uuid => @ballot.uuid,
          :voting_system_type => @ballot.voting_system_type,
          :instructions => @ballot.instructions,
          :notes => @ballot.notes,
          :ballot_configurations => @ballot.ballot_configurations.as_json(:only => [:key, :value]),
          :candidates => @ballot.candidates.as_json(),
          :candidatesIndex => candidatesIndex
        },
        :vote => {
          :uuid => @ballot_paper.uuid != nil ? nil : @ballot_paper.uuid, 
          :signature => @ballot_paper.signature, 
          :status => @ballot_paper.status, 
          :votes => @ballot_paper.votes.as_json(:only => [:candidate_id, :value, :value_type])
        }
      }, :status => 200 and return
      
    else
      render :json => {:error => @vote.errors.full_messages[0]}, :status => 400 and return
    end
  end

  
  #----------------------------------------------------------------------------

  private

  def ballot_paper_params
    params.require(:vote).permit(BallotPaper.permitted_params)
  end
end

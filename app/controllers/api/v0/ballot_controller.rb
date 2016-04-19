class API::V0::BallotController < ApplicationController
  include RangeVoting
  include PluralityVoting
  before_action :identify_ballot, :except => [:create]

  resource_description do
    api_version "v0"
    formats ["json"]
  end

  def_param_group :ballot_registration_fields do
    param :ballot_registration_fields, Array, :required => true, :desc => "Ballot registation fields associated with this ballot (an array of hashes)" do
      param :name, String, :desc => "Field name (e.g. First Name)", :required => true
      param :description, String, :desc => "Description of the field name (e.g. Enter your first name)", :required => true
      param :expected_value, String, :desc => "Expected value of the field (e.g. String or Integer)", :required => true
    end
  end

  #----------------------------------------------------------------------------
  # POST /api/v0/ballot

  api! "Create the ballot"

  param :ballot, Hash, :required => true, :desc => "Ballot hash containing the attributes" do
    param :password, String, :desc => "Password for the ballot", :required => true
    param :instructions, String, :desc => "Instructions for the ballot", :required => true
    param :notes, String, :desc => "Notes about this ballot", :required => true
    param :voting_system_type, Integer, :desc => "Type of voting system being used for this ballot", :required => true
    param :starts_at, String, :desc => "Time that this ballot starts (in YYYY-MM-DD HH:MM:SS format)", :required => true
    param :ends_at, String, :desc => "Time that this ballot ends (in YYYY-MM-DD HH:MM:SS format)", :required => true
  end

  # Note: Although we want an array of hashes, current ApiPie implementation doesn't
  # support this: https://github.com/Apipie/apipie-rails/issues/364
  param_group :ballot_registration_fields
  error 400, "Registration fields for ballot are missing"
  error 400, "Ballot#attribute is missing"
  example <<-EOS
    Sample request:
    ballot: {
      password: "abcdefg",
      instructions: "Fill out your first name",
      notes: "Notes about this ballot",
      voting_system_type: 1,
      starts_at: "2016-01-01 12:00",
      ends_at: "2017-01-01 12:00"
    }
  EOS
  def create
    @ballot = Ballot.new(ballot_params)

    if params[:ballot_registration_fields].blank?
      render :json => {:error => "Registration fields for ballot are missing"}, :status => 400 and return
    end

    unless @ballot.validate
      render :json => {:error => @ballot.errors.full_messages[0]}, :status => 400 and return
    end

    # At this point, we're guaranteed the ballot to have the necessary fields. Let's
    # iterate over the fields and make sure they're all sensible.
    fields = []
    ballot_registration_fields_params[:ballot_registration_fields].each_with_index do |reg_field, index|
      @registration_field = BallotRegistrationField.new(reg_field)
      @registration_field.position = index
      @registration_field.validate

      # Remove the empty ballot_id and check for errors.
      validation_errors = @registration_field.errors
      validation_errors.delete(:ballot_id)
      if validation_errors.present?
        render :json => {:error => @registration_field.errors.full_messages[0]}, :status => 400 and return
      else
        fields << @registration_field
      end
    end

    # At this point, the ballot and all of the registration fields are valid. Let's save the ballot and
    # associate the ballot to each of the registration fields.
    @ballot.save!
    fields.each do |field|
      field.ballot_id = @ballot.id
      field.save!
    end

    render :json => {}, :status => 200 and return
  end

  #----------------------------------------------------------------------------
  # GET /api/v0/ballot/:uuid/results

  # TODO: Implement module Plurality Voting and calculate return Number of YES - Number of NO
  api! "Retrieves the results for Ballot (may not necessarily be finished)"
  param_group :ballot, ApplicationController
  error 404, "Ballot does not exist"
  example <<-EOS
    Sample response: {
      ballot: {
        uuid: 52b59fbd-4b93-4227-b974-e1ba4a8c678d,
        finished: false
      }
      results: [{
        candidate_id: ...,
        values: [...],
        score: ...,
      }, ...]
    }
  EOS
  def results
    results = []
    results = @ballot.voting_system_type == "PLURALITY" ?    
      PluralityVoting.sort_candidates_by_score(@ballot.votes) : 
      RangeVoting.sort_candidates_by_score(@ballot.votes)
    indexedResults = Hash.new

    i = 0
    for result in results
      indexedResults[result[:contribution_uuid]] = {:vote => result, :position => i}
      i += 1
    end
      
    render :json => {
      :ballot  => {:uuid => @ballot.uuid, :finished => @ballot.finished?, :candidates => @ballot.candidates},
      :results => results, 
      :index => indexedResults
    }, :status => 200 and return
  end

  #----------------------------------------------------------------------------
  # GET /api/v0/ballot/:ballot_uuid/registration

  api! "Retrieves the VotingBallot registration form along with its fields and configuration."
  param_group :ballot, ApplicationController
  error 404, "Ballot does not exist"
  example <<-EOS
    Sample response:
      {
        ballot: {
          uuid: 52b59fbd-4b93-4227-b974-e1ba4a8c678d,
          password: ...,
          instructions: ...,
          notes: ...,
          voting_system_type: ...,
          starts_at: ...,
          ends_at: ...
        },
        ballot_configurations: [{
          key: ,
          value:
        }]
        ballot_registration_fields: [{
          name: ,
          description: ,
          expected_value:
        }]
      }
  EOS
  def registration_form
    render :json => {
      :ballot => @ballot.as_json(:except => [:id, :created_at, :updated_at]),
      :ballot_configurations => @ballot.ballot_configurations.as_json(:only => [:key, :value]),
      :ballot_registration_fields => @ballot.ballot_registration_fields.as_json(:except => [:ballot_id, :position])
    }, :status => 200 and return
  end

  #----------------------------------------------------------------------------
  # POST /api/v0/ballot/:ballot_uuid/registration

  api! %Q(Verifies the values provided by the user for each field in the
  VotingBallot registration form and responds with both the password for the
  VotingBallot and a specific generated "signature" for the voter. The
  signature will be used by the voter to retrieve their personal vote.)
  param_group :ballot, ApplicationController
  param_group :ballot_registration_fields
  error 404, "Ballot does not exist"
  error 400, "Registration form can't be empty"
  error 400, "Field name could not be found"
  error 400, "User input does not match the expected type"
  example <<-EOS
    Sample request:
    "ballot_registration_fields": [
      {
        name: "First Name",
        description: "Fill out your first name",
        expected_value: "string",
        user_input: "Dmitri"
      }, ...
    ]
    Sample response:
    {
      password: "...",
      signature: "..."
    }
  EOS
  def registration
    if ballot_registration_fields_params[:ballot_registration_fields].blank?
      render :json => {:error => "Registration form can't be empty"}, :status => 400 and return
    end

    registration_fields = @ballot.ballot_registration_fields
    ballot_registration_fields_params[:ballot_registration_fields].each do |reg_field|
      user_input = reg_field[:user_input]

      # Begin by finding matching registration field.
      matching_field = registration_fields.find_by_name(reg_field[:name])
      if matching_field.blank?
        render :json => {:error => "Field name could not be found"}, :status => 400 and return
      end

      # TODO: Right now, we have a very manual way of comparing field types. Ideally,
      # I'd get access to the appcivist repo so I can get the full list of accepted types
      # the app intends to use.
      # If we're expecting an integer, but it's a string, then let's throw an error.
      begin
        Float(user_input)
        if matching_field[:expected_value].downcase == "string"
          render :json => {:error => "User input does not match the expected type"}, :status => 400 and return
        end
      rescue
        if matching_field[:expected_value].downcase == "integer"
          render :json => {:error => "User input does not match the expected type"}, :status => 400 and return
        end
      end
    end

    # Create a signature from the registration fields.
    signature = BallotRegistrationField.generate_signature_from_params(ballot_registration_fields_params[:ballot_registration_fields])
    render :json => {:password => @ballot.password, :signature => signature}, :status => 200 and return
  end

  #----------------------------------------------------------------------------

  private

  def ballot_params
    params.require(:ballot).permit(Ballot.permitted_params)
  end

  def ballot_registration_fields_params
    params.permit(:ballot_registration_fields => BallotRegistrationField.permitted_params)
  end

end

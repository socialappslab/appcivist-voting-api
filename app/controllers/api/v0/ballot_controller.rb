class API::V0::BallotController < ApplicationController
  resource_description do
    api_version "v0"
    formats ["json"]
  end

  #----------------------------------------------------------------------------
  # POST /api/v0/ballot

  api! "Create the ballot"

  param :ballot, Hash, :required => true, :desc => "Ballot hash containing the attributes" do
    param :password, String, :desc => "Password for the ballot"
    param :instructions, String, :desc => "Instructions for the ballot", :required => true
    param :notes, String, :desc => "Notes about this ballot", :required => true
    param :voting_system_type, Integer, :desc => "Type of voting system being used for this ballot", :required => true
    param :starts_at, String, :desc => "Time that this ballot starts (in YYYY-MM-DD HH:MM:SS format)", :required => true
    param :ends_at, String, :desc => "Time that this ballot ends (in YYYY-MM-DD HH:MM:SS format)", :required => true
  end

  # Note: Although we want an array of hashes, current ApiPie implementation doesn't
  # support this: https://github.com/Apipie/apipie-rails/issues/364
  param :ballot_registration_fields, Array, :required => true, :desc => "Ballot registation fields associated with this ballot (an array of hashes)" do
    param :name, String, :desc => "Field name (e.g. First Name)"
    param :description, String, :desc => "Description of the field name (e.g. Enter your first name)", :required => true
    param :expected_value, String, :desc => "Expected value of the field (e.g. String or Integer)", :required => true
  end
  error 400, "Registration fields for ballot are missing"
  error 400, "Ballot#attribute is missing"
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

  private

  def ballot_params
    params.require(:ballot).permit(Ballot.permitted_params)
  end

  def ballot_registration_fields_params
    params.permit(:ballot_registration_fields => BallotRegistrationField.permitted_params.to_a)
  end

end

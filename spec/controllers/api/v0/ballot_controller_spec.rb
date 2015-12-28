require 'rails_helper'
require 'digest/sha1'

RSpec.describe API::V0::BallotController, type: :controller do
  render_views

  describe "Creating ballots" do
    let(:ballot_params) { attributes_for(:ballot) }
    let(:ballot_fields_params) { [attributes_for(:age_field), attributes_for(:first_name_field)] }

    it "increments Ballot count" do
      expect {
        post :create, :ballot => ballot_params, :ballot_registration_fields => ballot_fields_params, :format => :json
      }.to change(Ballot, :count).by(1)
    end

    it "incremenets BallotRegistrationField count" do
      expect {
        post :create, :ballot => ballot_params, :ballot_registration_fields => ballot_fields_params, :format => :json
      }.to change(BallotRegistrationField, :count).by(2)
    end

    it "associates a ballot with the registration fields" do
      post :create, :ballot => ballot_params, :ballot_registration_fields => ballot_fields_params, :format => :json
      BallotRegistrationField.find_each do |brf|
        expect(brf.ballot_id).not_to eq(nil)
      end
    end

    it "returns proper status code" do
      post :create, :ballot => ballot_params, :ballot_registration_fields => ballot_fields_params, :format => :json
      expect(response.status).to eq(200)
    end

    it "returns proper error if regisration field are missing" do
      post :create, :ballot => ballot_params, :ballot_registration_fields => [], :format => :json
      expect(JSON.parse(response.body)["error"]).to eq("Registration fields for ballot are missing")
    end

    it "returns proper error code" do
      post :create, :ballot => ballot_params.merge("instructions" => nil), :ballot_registration_fields => ballot_fields_params, :format => :json
      expect(response.status).to eq(400)
    end

    it "assigns attributes to ballot" do
      post :create, :ballot => ballot_params, :ballot_registration_fields => ballot_fields_params, :format => :json
      b = Ballot.last
      expect(b.uuid).not_to eq(nil)
      expect(b.password).to eq("abcdefg")
      expect(b.notes).to eq("Ballot notes")
      expect(b.instructions).to eq("Ballot instructions")
      expect(b.starts_at.strftime("%Y-%m-%d %H:%M:%S")).to eq("2016-01-01 12:00:00")
      expect(b.ends_at.strftime("%Y-%m-%d %H:%M:%S")).to eq("2017-01-01 12:00:00")
    end
  end


  describe "Retrieving a ballot with its registration fields" do
    let(:ballot) { create(:ballot) }

    before(:each) do
      create(:first_name_field, :ballot => ballot, :position => 0)
      create(:age_field, :ballot => ballot, :position => 1)
    end

    it "returns the proper ballot" do
      get :registration_form, :ballot_uuid => ballot.uuid
      resp = JSON.parse(response.body)
      expect(resp["ballot"]["uuid"]).to eq(ballot.uuid)
    end

    it "returns the proper registration fields" do
      get :registration_form, :ballot_uuid => ballot.uuid
      resp = JSON.parse(response.body)
      expect(resp["ballot_registration_fields"][0]["name"]).to eq("First Name")
      expect(resp["ballot_registration_fields"][1]["name"]).to eq("Your age")
    end

    it "returns not found if ballot was not found" do
      get :registration_form, :ballot_uuid => "123"
      expect(JSON.parse(response.body)["error"]).to eq("Ballot does not exist")
    end

  end

  describe "Registering for the ballot" do
    let!(:ballot) { create(:ballot) }
    let(:field1) { create(:first_name_field, :ballot => ballot, :position => 0)}
    let(:field2) { create(:age_field, :ballot => ballot, :position => 1)}
    let(:fields) { [field1.attributes.merge(:user_input => "Dmitri"), field2.attributes.merge(:user_input => 27)] }

    it "returns error when registration fields are empty" do
      post :registration, :ballot_uuid => ballot.uuid, :ballot_registration_fields => []
      expect(JSON.parse(response.body)["error"]).to eq("Registration form can't be empty")
    end

    it "returns error when name is not a string" do
      post :registration, :ballot_uuid => ballot.uuid, :ballot_registration_fields => [field1.attributes.merge(:user_input => 10)]
      expect(JSON.parse(response.body)["error"]).to eq("User input does not match the expected type")
    end

    it "returns error when name is not a string" do
      post :registration, :ballot_uuid => ballot.uuid, :ballot_registration_fields => [field2.attributes.merge(:user_input => "Test")]
      expect(JSON.parse(response.body)["error"]).to eq("User input does not match the expected type")
    end

    it "returns correct password and signature" do
      post :registration, :ballot_uuid => ballot.uuid, :ballot_registration_fields => fields
      resp = JSON.parse(response.body)
      expect(resp["password"]).to eq(ballot.password)
      expect(resp["signature"]).to eq( Digest::SHA1.hexdigest("dmitri27") )
    end

    it "increments Vote" do
      expect {
        post :registration, :ballot_uuid => ballot.uuid, :ballot_registration_fields => fields
      }.to change(Vote, :count).by(1)
    end

    it "creates correct Vote attributes" do
      post :registration, :ballot_uuid => ballot.uuid, :ballot_registration_fields => fields
      v = Vote.last
      signature = JSON.parse(response.body)["signature"]
      expect(v.signature).to eq(signature)
      expect(v.ballot_id).to eq(ballot.id)
      expect(v.candidate_id).not_to eq(nil)
      expect(v.status).to eq(Vote::Status::DRAFT)
    end

    it "increments Candidate" do
      expect {
        post :registration, :ballot_uuid => ballot.uuid, :ballot_registration_fields => fields
      }.to change(Candidate, :count).by(1)
    end

    it "creates correct Candidate attributes" do
      post :registration, :ballot_uuid => ballot.uuid, :ballot_registration_fields => fields
      c = Candidate.last
      expect(c.ballot_id).to eq(ballot.id)
    end
  end


end

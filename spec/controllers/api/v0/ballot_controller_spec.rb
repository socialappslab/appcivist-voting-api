require 'rails_helper'

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




end

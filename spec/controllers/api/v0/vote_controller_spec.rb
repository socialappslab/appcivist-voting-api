require 'rails_helper'
require 'digest/sha1'

RSpec.describe API::V0::VoteController, type: :controller do
  render_views

  describe "Creating votes" do
    let(:ballot)    { create(:ballot) }
    let(:candidate) { build(:candidate, :ballot => ballot) }
    let(:signature) { Digest::SHA1.hexdigest("dmitri27") }

    before(:each) do
      candidate.save(:validate => false)
    end

    it "increments Vote" do
      expect {
        post :create, :ballot_uuid => ballot.uuid, :candidate_uuid => candidate.uuid, :signature => signature
      }.to change(Vote, :count).by(1)
    end

    it "creates correct Vote attributes" do
      post :create, :ballot_uuid => ballot.uuid, :candidate_uuid => candidate.uuid, :signature => signature
      v = Vote.last
      signature = JSON.parse(response.body)["signature"]
      expect(v.signature).to eq(signature)
      expect(v.ballot_id).to eq(ballot.id)
      expect(v.candidate_id).to eq(candidate.id)
      expect(v.status).to eq(Vote::Status::DRAFT)
      expect(v.value).to eq(nil)
      expect(v.value_type).to eq(nil)
    end

    it "returns error if no ballot is found" do
      post :create, :ballot_uuid => "test", :candidate_uuid => candidate.uuid, :signature => signature
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)["error"]).to eq("Ballot does not exist")
    end

    it "returns error if no candidate is found" do
      post :create, :ballot_uuid => ballot.uuid, :candidate_uuid => nil, :signature => signature
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)["error"]).to eq("Candidate does not exist")
    end

    it "returns error if signature is missing" do
      post :create, :ballot_uuid => ballot.uuid, :candidate_uuid => candidate.uuid, :signature => nil
      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)["error"]).to eq("Signature can't be blank")
    end

  end

end

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
        post :create, :ballot_uuid => ballot.uuid, :candidate_uuid => candidate.uuid, :vote => {:signature => signature}
      }.to change(Vote, :count).by(1)
    end

    it "creates correct Vote attributes" do
      post :create, :ballot_uuid => ballot.uuid, :candidate_uuid => candidate.uuid, :vote => {:signature => signature}
      v = Vote.last
      signature = JSON.parse(response.body)["vote"]["signature"]
      expect(v.signature).to eq(signature)
      expect(v.ballot_id).to eq(ballot.id)
      expect(v.candidate_id).to eq(candidate.id)
      expect(v.status).to eq(Vote::Status::DRAFT)
      expect(v.value).to eq(nil)
      expect(v.value_type).to eq(nil)
    end

    it "returns error if no ballot is found" do
      post :create, :ballot_uuid => "test", :candidate_uuid => candidate.uuid, :vote => {:signature => signature}
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)["error"]).to eq("Ballot does not exist")
    end

    it "returns error if no candidate is found" do
      post :create, :ballot_uuid => ballot.uuid, :candidate_uuid => nil, :vote => {:signature => signature}
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)["error"]).to eq("Candidate does not exist")
    end

    it "returns error if signature is missing" do
      post :create, :ballot_uuid => ballot.uuid, :candidate_uuid => candidate.uuid, :vote => {:signature => nil}
      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)["error"]).to eq("Signature can't be blank")
    end

  end

  describe "Retrieving votes" do
    let(:ballot)    { create(:ballot) }
    let(:candidate) { build(:candidate, :ballot => ballot) }
    let(:vote)      { build(:dmitri_vote, :ballot => ballot)}

    before(:each) do
      candidate.save(:validate => false)
      vote.candidate = candidate
      vote.save(:validate => false)
    end

    it "returns error if no ballot is found" do
      get :show, :ballot_uuid => "test", :signature => vote.signature
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)["error"]).to eq("Ballot does not exist")
    end

    it "returns empty vote object if vote does not exist" do
      vote = create(:vote, :ballot_id => 999, :candidate_id => 1, :signature => "test", :status => Vote::Status::DRAFT)
      get :show, :ballot_uuid => ballot.uuid, :signature => "test"
      expect(JSON.parse(response.body)["vote"]).to eq({})
    end

    it "returns correct Vote and Ballot instance" do
      get :show, :ballot_uuid => ballot.uuid, :signature => vote.signature
      vote_object   = JSON.parse(response.body)["vote"]
      ballot_object = JSON.parse(response.body)["ballot"]

      expect(vote_object["signature"]).to eq(vote.signature)
      expect(vote_object["status"]).to eq(vote.status)
      expect(vote_object["value"]).to eq(vote.value)
      expect(vote_object["value_type"]).to eq(vote.value_type)

      expect(ballot_object["uuid"]).to eq(ballot.uuid)
      expect(ballot_object["voting_system_type"]).to eq(ballot.voting_system_type)
    end
  end


  describe "Updating votes" do
    let(:ballot)    { create(:ballot) }
    let(:candidate) { build(:candidate, :ballot => ballot) }
    let(:vote)      { build(:dmitri_vote, :ballot => ballot, :value_type => 1)}

    before(:each) do
      candidate.save(:validate => false)
      vote.candidate = candidate
      vote.save(:validate => false)
    end

    it "returns error if no ballot is found" do
      get :show, :ballot_uuid => "test", :signature => vote.signature
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)["error"]).to eq("Ballot does not exist")
    end

    it "returns error if vote is not found" do
      vote = create(:vote, :ballot_id => 999, :candidate_id => 1, :signature => "test", :status => Vote::Status::DRAFT)
      put :update, :ballot_uuid => ballot.uuid, :signature => "test", :vote => {:value => ""}
      expect(JSON.parse(response.body)["error"]).to eq("Vote does not exist")
    end

    it "updates Vote instance" do
      put :update, :ballot_uuid => ballot.uuid, :signature => vote.signature, :vote => {:value => "test"}
      v = Vote.last
      expect(v.value).to eq("test")
    end
  end

end

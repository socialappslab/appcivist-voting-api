require 'rails_helper'
require 'digest/sha1'

RSpec.describe API::V0::VoteController, type: :controller do
  render_views

  describe "Creating votes" do
    let(:ballot)    { create(:ballot) }
    let(:signature) { Digest::SHA1.hexdigest("dmitri27") }

    it "increments BallotPaper" do
      expect {
        post :create, :ballot_uuid => ballot.uuid, :vote => {:signature => signature}
      }.to change(BallotPaper, :count).by(1)
    end

    it "creates correct BallotPaper attributes" do
      post :create, :ballot_uuid => ballot.uuid, :vote => {:signature => signature}
      v = BallotPaper.last
      signature = JSON.parse(response.body)["vote"]["signature"]
      expect(v.signature).to eq(signature)
      expect(v.ballot_id).to eq(ballot.id)
      expect(v.status).to eq(BallotPaper::Status::DRAFT)
    end

    it "returns error if no ballot is found" do
      post :create, :ballot_uuid => "test", :vote => {:signature => signature}
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)["error"]).to eq("Ballot does not exist")
    end

    it "returns error if signature is missing" do
      post :create, :ballot_uuid => ballot.uuid, :vote => {:signature => nil}
      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)["error"]).to eq("Signature can't be blank")
    end

    it "returns error if signature already exists" do
      post :create, :ballot_uuid => ballot.uuid, :vote => {:signature => signature}
      post :create, :ballot_uuid => ballot.uuid, :vote => {:signature => signature}
      expect(response.status).to eq(409)
      expect(JSON.parse(response.body)["error"]).to eq("Ballot with that signature already exists")
    end
  end

  describe "Retrieving votes" do
    let(:ballot)       { create(:ballot) }
    let(:ballot_paper) { create(:ballot_paper, :ballot => ballot)}

    before(:each) do
      3.times do |index|
        c = build(:candidate, :ballot => ballot)
        c.save(:validate => false)
        v = create(:vote, :candidate => c, :ballot_paper_id => ballot_paper.id)
      end
    end

    it "returns error if no ballot is found" do
      get :show, :ballot_uuid => "test", :signature => ballot_paper.signature, :format => :json
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)["error"]).to eq("Ballot does not exist")
    end

    it "returns empty object if ballot paper does not exist" do
      new_ballot = create(:ballot)
      get :show, :ballot_uuid => new_ballot.uuid, :signature => "test", :format => :json
      expect(JSON.parse(response.body)["vote"]).to eq({})
    end

    it "returns correct Ballot instance" do
      get :show, :ballot_uuid => ballot.uuid, :signature => ballot_paper.signature, :format => :json
      ballot_object = JSON.parse(response.body)["ballot"]
      expect(ballot_object["uuid"]).to eq(ballot.uuid)
      expect(ballot_object["voting_system_type"]).to eq(ballot.voting_system_type)
    end

    it "returns correct Vote instance" do
      get :show, :ballot_uuid => ballot.uuid, :signature => ballot_paper.signature, :format => :json
      vote_object   = JSON.parse(response.body)["vote"]

      expect(vote_object["signature"]).to eq(ballot_paper.signature)
      expect(vote_object["status"]).to eq(ballot_paper.status)

      candidate_ids = ballot_paper.votes.pluck(:candidate_id)
      vote_object["votes"].each do |v|
        expect(candidate_ids).to include(v["candidate_id"])
      end
    end
  end


  describe "Updating votes" do
    let(:ballot)       { create(:ballot) }
    let(:ballot_paper) { create(:ballot_paper, :ballot => ballot)}

    it "returns error if no ballot is found" do
      get :show, :ballot_uuid => "test", :signature => ballot_paper.signature
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)["error"]).to eq("Ballot does not exist")
    end

    it "returns error if ballot paper is not found" do
      new_ballot = create(:ballot)
      put :update, :ballot_uuid => new_ballot.uuid, :signature => "test", :vote => {:value => ""}
      expect(JSON.parse(response.body)["error"]).to eq("Ballot paper does not exist")
    end

    it "updates BallotPaper status" do
      put :update, :ballot_uuid => ballot.uuid, :signature => ballot_paper.signature, :vote => {:status => 1}
      expect(BallotPaper.last.status).to eq(1)
    end
  end

end

# -*- encoding : utf-8 -*-
require "rails_helper"

describe RangeVoting do
  let(:ballot) { create(:ballot) }

  before(:each) do

    # Crate 3 candidates.
    3.times do |index|
      build(:candidate, :ballot => ballot, :candidate_type => 0, :uuid => "index-#{index}").save(:validate => false)
    end

    # Create 5 voters.
    5.times do |index|
      bp = create(:ballot_paper, :ballot => ballot, :signature => "index-#{index}", :status => BallotPaper::Status::DRAFT)
    end

    # Create 5 votes for 1st candidate (expected loser)
    c = Candidate.find_by_uuid("index-0")
    BallotPaper.find_each do |bp|
      create(:vote, :candidate => c, :ballot_paper => bp, :value => 1)
    end

    # Create 3 votes for 2nd candidate (expected winner)
    c = Candidate.find_by_uuid("index-1")
    BallotPaper.limit(3).to_a.each do |bp|
      create(:vote, :candidate => c, :ballot_paper => bp, :value => 9)
    end

    # Create 5 votes for 3rd candidate (expected second place)
    c = Candidate.find_by_uuid("index-2")
    BallotPaper.find_each do |bp|
      create(:vote, :candidate => c, :ballot_paper => bp, :value => 5)
    end
  end

  it "correctly calculates score" do
    expect(RangeVoting.calculate_score(["1", "2", "3"])).to eq(2.0)
  end

  it "correctly calculates score" do
    expect(RangeVoting.calculate_score(["9", "1", "9"])).to eq(6.33)
  end

  it "returns correct order for candidates" do
    sorted_cands = RangeVoting.sort_candidates_by_score(ballot.votes)

    c = Candidate.find_by_uuid("index-1")
    expect(sorted_cands[0][:candidate_id]).to eq(c.id)

    c = Candidate.find_by_uuid("index-2")
    expect(sorted_cands[1][:candidate_id]).to eq(c.id)

    c = Candidate.find_by_uuid("index-0")
    expect(sorted_cands[2][:candidate_id]).to eq(c.id)
  end

  it "returns values for each candidate" do
    sorted_cands = RangeVoting.sort_candidates_by_score(ballot.votes)

    c = Candidate.find_by_uuid("index-1")
    expect(sorted_cands[0][:values]).to eq(["9", "9", "9"])

    c = Candidate.find_by_uuid("index-2")
    expect(sorted_cands[1][:values]).to eq(["5", "5", "5", "5", "5"])

    c = Candidate.find_by_uuid("index-0")
    expect(sorted_cands[2][:values]).to eq(["1", "1", "1", "1", "1"])
  end
end

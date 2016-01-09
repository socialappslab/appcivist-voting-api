# encoding: utf-8
require 'rails_helper'
require 'digest/sha1'

describe BallotConfiguration do
  it "validates on presence of ballot_id" do
    b = build_stubbed(:ballot_configuration); b.validate
    expect(b.errors.keys).to include(:ballot_id)
  end

  it "validates on presence of position" do
    b = build_stubbed(:ballot_configuration); b.validate
    expect(b.errors.keys).to include(:position)
  end

  it "validates on presence of key" do
    b = build_stubbed(:ballot_configuration); b.validate
    expect(b.errors.keys).to include(:key)
  end

  it "validates on presence of value" do
    b = build_stubbed(:ballot_configuration); b.validate
    expect(b.errors.keys).to include(:value)
  end
end

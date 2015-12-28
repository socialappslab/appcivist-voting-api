# encoding: utf-8
require 'rails_helper'
require 'digest/sha1'

describe BallotRegistrationField do
  it "validates on presence of name" do
    b = build_stubbed(:ballot_registration_field, :name => ""); b.validate
    expect(b.errors.keys).to include(:name)
  end

  it "validates on presence of description" do
    b = build_stubbed(:ballot_registration_field, :description => ""); b.validate
    expect(b.errors.keys).to include(:description)
  end

  it "validates on presence of expected value" do
    b = build_stubbed(:ballot_registration_field, :expected_value => ""); b.validate
    expect(b.errors.keys).to include(:expected_value)
  end

  describe "Signature" do
    it "generates a proper signature" do
      params = [{:name => "First Name", :user_input => "Dmitri"}, {:name => "Your age", :user_input => 37}]
      signature = BallotRegistrationField.generate_signature_from_params(params)
      expect(signature).to eq( Digest::SHA1.hexdigest("dmitri37") )
    end
  end
end

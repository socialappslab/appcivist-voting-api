require 'digest/sha1'

FactoryGirl.define do
  factory :ballot do
    password "abcdefg"
    instructions "Ballot instructions"
    notes "Ballot notes"
    voting_system_type "RANGE"
    starts_at "2016-01-01 12:00:00"
    ends_at   "2017-01-01 12:00:00"
  end

  factory :ballot_paper do
    status    BallotPaper::Status::DRAFT
    signature Digest::SHA1.hexdigest("dmitri27")
  end

  factory :ballot_registration_field do
    factory :first_name_field do
      name "First Name"
      description "Enter your first name"
      expected_value "string"
    end

    factory :age_field do
      name "Your age"
      description "Enter your age"
      expected_value "integer"
    end
  end

  factory :candidate
  factory :vote
  factory :ballot_configuration
end

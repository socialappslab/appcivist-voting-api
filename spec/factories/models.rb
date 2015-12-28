FactoryGirl.define do
  factory :ballot do
    password "abcdefg"
    instructions "Ballot instructions"
    notes "Ballot notes"
    voting_system_type 0
    starts_at "2016-01-01 12:00:00"
    ends_at   "2017-01-01 12:00:00"
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
end

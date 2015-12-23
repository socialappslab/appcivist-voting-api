class CreateBallotRegistrationFields < ActiveRecord::Migration
  def change
    create_table :ballot_registration_fields do |t|
      t.integer :ballot_id
      t.string  :name
      t.text    :description
      t.string  :expected_value
      t.integer :position, :default => 0
    end
  end
end

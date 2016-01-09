class CreateBallotConfiguration < ActiveRecord::Migration
  def change
    create_table :ballot_configurations do |t|
      t.integer :ballot_id
      t.string  :rule
      t.text    :description
      t.integer :position
    end
  end
end

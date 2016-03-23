class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :candidate_id
      t.integer :ballot_id
      t.string  :signature, :unique => true
      t.string  :status
      t.string  :value
      t.integer :value_type

      t.timestamps
    end

    # Create a UNIQUE index on the UUID as we'll be doing a lot of lookups by it.
    add_index :votes, :signature, :unique => true
  end
end

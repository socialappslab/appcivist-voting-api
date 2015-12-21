class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.integer :ballot_id
      t.string  :uuid, :unique => true
      t.integer :candidate_type
      t.uuid    :contribution_uuid

      t.timestamps
    end

    # Create a UNIQUE index on the UUID as we'll be doing a lot of lookups by it.
    add_index :candidates, :uuid, :unique => true
  end
end

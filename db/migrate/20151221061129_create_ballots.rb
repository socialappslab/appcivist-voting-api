class CreateBallots < ActiveRecord::Migration
  def change
    create_table :ballots do |t|
      t.string   :uuid, :unique => true
      t.string   :password
      t.text     :instructions
      t.text     :notes
      t.integer  :voting_system_type
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end

    # Create a UNIQUE index on the UUID as we'll be doing a lot of lookups by it.
    add_index :ballots, :uuid, :unique => true
  end
end

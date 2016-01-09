class ChangeBallotVotingType < ActiveRecord::Migration
  def change
    change_column :ballots, :voting_system_type, :string
  end
end

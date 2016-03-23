class ChangeColumnsOnBallotConfiguration < ActiveRecord::Migration
  def change
    rename_column :ballot_configurations, :rule, :key
    change_column :ballot_configurations, :description, :string
    rename_column :ballot_configurations, :description, :value
  end
end

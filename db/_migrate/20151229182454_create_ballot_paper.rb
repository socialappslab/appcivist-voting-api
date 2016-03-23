class CreateBallotPaper < ActiveRecord::Migration
  def up
    create_table :ballot_papers do |t|
      t.integer :ballot_id
      t.string  :uuid
      t.string  :signature
      t.integer :status

      t.timestamps
    end

    rename_column :votes, :ballot_id, :ballot_paper_id
    remove_column :votes, :signature
    remove_column :votes, :status
  end

  def down
    add_column :votes, :status, :string
    add_column :votes, :signature, :string
    rename_column :votes, :ballot_paper_id, :ballot_id
    drop_table :ballot_papers
  end
end

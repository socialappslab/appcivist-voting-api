class RemoveUniqueIndexOnSignature < ActiveRecord::Migration
  def change
    remove_index :votes, :signature
    add_index :votes, :signature
  end
end

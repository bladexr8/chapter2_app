class AddIndexToUsersEmail < ActiveRecord::Migration
  def change
    # add an index constraint to table to guarantee uniqueness at DB level
    add_index :users, :email, unique: true
  end
end

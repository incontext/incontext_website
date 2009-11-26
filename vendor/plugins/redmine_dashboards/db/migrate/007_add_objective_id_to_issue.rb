class AddObjectiveIdToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :objective_id, :integer
  end

  def self.down
    remove_column :issues, :objective_id
  end
end

class MakeObjectiveParentNull < ActiveRecord::Migration
  def self.up
    change_column :objectives, :parent_id, :integer, :null => true
  end
  def self.down
    change_column :objectives, :parent_id, :integer
  end
end

class RenameActionToObjective < ActiveRecord::Migration
  def self.up
    rename_table :d_actions, :objectives
  end

  def self.down
    rename_table :objectives, :d_actions
  end
end


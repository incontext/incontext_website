class AddDescriptionToActions < ActiveRecord::Migration
  def self.up
    add_column :d_actions, :description, :string
  end

  def self.down
    remove_column :d_actions, :description
  end
end

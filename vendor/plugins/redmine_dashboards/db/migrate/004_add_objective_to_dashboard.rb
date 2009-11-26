class AddObjectiveToDashboard < ActiveRecord::Migration
  def self.up
    add_column :dashboards, :objective, :string
    add_column :dashboards, :risk_rating, :string
  end

  def self.down
    remove_column :dashboards, :risk_rating
    remove_column :dashboards, :objective
  end
end

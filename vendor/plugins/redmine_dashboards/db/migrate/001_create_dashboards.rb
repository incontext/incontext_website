class CreateDashboards < ActiveRecord::Migration
  def self.up
    create_table :dashboards do |t|
      t.column :name, :string
      t.column :description, :string
      t.integer :project_id
    end
  end

  def self.down
    drop_table :dashboards
  end
end

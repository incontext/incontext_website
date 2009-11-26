class CreateDActions < ActiveRecord::Migration
  def self.up
    create_table :d_actions do |t|
      t.integer :dashboard_id, :null => false
      t.string :name, :null => false
      t.string :risk_rating
      t.integer :sequence, :null => false
      t.integer :parent_id, :null => false
    end
  end

  def self.down
    drop_table :d_actions
  end
end

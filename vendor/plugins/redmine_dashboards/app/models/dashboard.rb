class Dashboard < ActiveRecord::Base
  belongs_to :project
  has_many :objectives

  validates_presence_of :name, :description
  validates_length_of :name, :maximum => 70
  validates_length_of :description, :maximum => 250
  validates_length_of :objective, :maximum => 250
  validates_uniqueness_of :project_id, :message => 'Only one dashboard can be created in a project'

  def unassigned_objectives
    self.objectives.find(:all, :conditions => 'parent_id is null')
  end
end

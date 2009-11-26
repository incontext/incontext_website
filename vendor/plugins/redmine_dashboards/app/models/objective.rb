
class Objective < ActiveRecord::Base
  acts_as_tree
  belongs_to :dashboard
  has_many   :issues

  validates_length_of :description, :maximum => 250
  validates_presence_of :name, :sequence
  after_destroy :destroy_children

  def next_sequence
    sql = " select max(sequence) as max_sequence
            from objectives
            where dashboard_id = #{self.dashboard_id}"

    sql += self.parent_id ? " and parent_id = #{self.parent_id} " : " and parent_id = 0 "
    Objective.find_by_sql(sql).first.max_sequence.to_i + 1
  end

  def next_level
    next_level = []
    Objective.find(:all,
      :select => 'id',
      :conditions => "parent_id = #{self.parent_id}").each do |o|
      next_level += o.children
    end
    next_level
  end

  def ancestors_path
    (ancestors.reverse << self).map {|v| v.sequence }.join('.')
  end

  private
  def destroy_children
    self.children.each do |c|
      c.destroy
    end
  end
end

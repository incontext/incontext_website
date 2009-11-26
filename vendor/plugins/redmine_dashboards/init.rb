require 'redmine'

require 'dispatcher'
require 'issue_objective_patch'
require 'query_objective_patch'
Dispatcher.to_prepare do
  Issue.send(:include, IssueObjectivePatch)
  Query.send(:include, QueryObjectivePatch)
end

# Hooks
require_dependency 'objective_issue_hook'

Redmine::Plugin.register :redmine_dashboards do
  name 'Redmine Dashboards plugin'
  author 'InContext'
  description 'This is a dashboard plugin for Redmine'
  version '0.0.1'

  project_module :dashboards do
    permission :view_dashboards, :dashboards => [:index, :print], :objectives => [:history, :issues]
    permission :edit_dashboard, :dashboards => [:edit, :edit_objectives, :new, :sort, :update_category], :objectives => [:edit, :new, :destroy, :update, :create]
  end

  menu :project_menu, :dashboards,
    { :controller => :dashboards, :action => :index },
    :caption => 'Dashboards',
    :after => :files,
    :param => :project_id
end

# this is horrible way to do wiki macro, dont know if redmine has better way to do it at this stage
Redmine::WikiFormatting::Macros.register do
  desc "include dashboard in wiki"
  macro :dashboard do |obj, args|
    @project = Project.find(args[0])
    allowed = User.current.allowed_to?({:controller => 'dashboards', :action => 'index'}, @project)
    if allowed
      @dashboard  = Dashboard.find_by_project_id(@project.id)
      col_num = @dashboard.objectives.find(:all, :conditions => 'parent_id = 0').size

      row_num = 0
      @dashboard.objectives.find(:all, :conditions => 'parent_id = 0').each do |x|
        count = @dashboard.objectives.find(:all, :conditions => "parent_id = #{x.id}").size
        row_num = count if count > row_num
      end

      row_num += 1

      objectives  = Array.new(col_num)
      objectives .map! { Array.new(row_num) }
      @dashboard.objectives.find(:all, :conditions => 'parent_id = 0', :order => 'sequence').each_with_index do |x, x_index|
        objectives[x_index][0] = x
        @dashboard.objectives.find(:all, :conditions => "parent_id = #{x.id}", :order => 'sequence').each_with_index do |y, y_index|
          objectives[x_index][1 + y_index] = y
        end
      end
      @formatted_objectives = Array.new(row_num)
      @formatted_objectives .map! { Array.new(col_num) }
      objectives.each_with_index do |x, x_index|
        x.each_with_index do |y, y_index|
          @formatted_objectives[y_index][x_index] = objectives[x_index][y_index]
        end
      end

      @col_num = @formatted_objectives.first.size

      haml_content = File.open(File.join(File.dirname(__FILE__), 'app', 'views', 'dashboards', '_dashboard.haml')).read
      out = Haml::Engine.new(haml_content).render(Object.new, { :dashboard => @dashboard, :formatted_objectives => @formatted_objectives, :col_num => @col_num, :controller => nil })
      out << stylesheet_link_tag('dashboard', :plugin => 'redmine_dashboards')
    else
      raise "Access to project #{@project.name}'s dashboard denied"
    end
  end
end

Redmine::WikiFormatting::Macros.register do
  desc "dashboard's legend in wiki"
  macro :legend do |obj, args|
    haml = File.open(File.join(File.dirname(__FILE__), 'app', 'views', 'dashboards', '_legend.haml')).read
    out = Haml::Engine.new(haml).render
    out << stylesheet_link_tag('dashboard', :plugin => 'redmine_dashboards')
  end
end

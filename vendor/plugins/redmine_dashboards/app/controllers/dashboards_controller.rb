class DashboardsController < ApplicationController
  unloadable

  audit Dashboard

  before_filter :find_project, :authorize, :only => [:index, :new, :edit, :edit_objectives, :print, :sort, :update_category]

  def index
    @dashboard = Dashboard.find_by_project_id(@project.id)
    if @dashboard
      @formatted_objectives = format_objectives(@dashboard)
      @col_num = @formatted_objectives.first.size
    end
  end

  def print
    @dashboard = Dashboard.find_by_project_id(@project.id)
    if @dashboard
      @formatted_objectives = format_objectives(@dashboard)
      @col_num = @formatted_objectives.first.size
    end
    render :layout => false
  end

  def new
    @dashboard = Dashboard.new( :project_id => @project.id )
  end

  def edit
    @dashboard = Dashboard.find(params[:id])
    @formatted_objectives = format_objectives(@dashboard)
    @col_num = @formatted_objectives.first.size

    render :update do |page|
      page.replace_html 'edit_dashboard_area', :partial => 'edit'
      page.show 'edit_dashboard_area'
    end
  end

  def edit_objectives
    @dashboard = Dashboard.find(params[:id])
    @formatted_objectives = format_objectives(@dashboard)
    @col_num = @formatted_objectives.first.size
  end

  def sort
    @dashboard = Dashboard.find(params[:id])
    params["objectives"].each_with_index do |x, index|
      Objective.find(x).update_attributes(:sequence => index + 1)
    end
    render :nothing => true
  end

  def update_category
    @dashboard = Dashboard.find(params[:id])
    parent = Objective.find(params[:objective_parent_id].split('_')[1]) if params[:objective_parent_id]
    child = Objective.find(params[:objective_child_id].split('_')[1]) if params[:objective_child_id]
    if child.parent_id != parent.parent_id
      child.parent_id = parent.id
      child.save!
      render :text => 0
    else
      render :text => 1
    end
  end

  def retrive
    @dashboard = Dashboard.find(params[:id])
    @parent = Objective.find(params[:parent_id])
    @children = Objective.find_all_by_parent_id(@parent.id)
    @siblings = Objective.find_all_by_parent_id(@parent.parent_id)
    update_div = @parent.parent_id == 0 ? 'sortable_b' : 'sortable_c'
    end_reached = (@parent.parent_id != 0)
    render :update do |page|
      page.replace_html(update_div,
        :partial => 'low_level_objectives',
        :locals => {
          :children => @children,
          :parent => @parent,
          :siblings => @siblings,
          :dashboard => @dashboard,
          :end_reached => end_reached})
      page.replace_html('sortable_c', '') if @parent.parent_id == 0
      @siblings.each do |s|
        page.call 'Element.removeClassName', "objectives_#{s.id}", 'current'
      end
      page.call 'Element.addClassName', "objectives_#{@parent.id}", 'current'
    end
  end

  def create
    @dashboard = Dashboard.new(params[:dashboard])
    if @dashboard.save
      flash[:notice] = 'New dashboard created successfully'
      redirect_to dashboards_path(:project_id => @dashboard.project_id)
    else
      render :action => :new, :project_id => @dashboard.project_id
    end
  end

  def update
    @dashboard = Dashboard.find(params[:id])

    render :update do |page|
      if @dashboard.update_attributes(params[:dashboard])
        flash[:notice] = 'Dashboard updated successfully'
        page.hide 'edit_dashboard_area'
        page.replace_html "dashboard_#{@dashboard.id}_name", @dashboard.name
        page.replace_html "dashboard_#{@dashboard.id}_description", @dashboard.description
        page.replace_html "dashboard_#{@dashboard.id}_objective", @dashboard.objective
        page.replace_html "dashboard_#{@dashboard.id}_risk_rating", "<span class = '#{@dashboard.risk_rating}'>#{@dashboard.risk_rating}</span>"
      else
        page.replace_html 'edit_dashboard_area', :partial => 'edit'
      end
    end
  end

  protected

  def current_user
    @user ||= User.current
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def format_objectives(dashboard)
    col_num = dashboard.objectives.find(:all, :conditions => 'parent_id = 0').size

    row_num = 0
    dashboard.objectives.find(:all, :conditions => 'parent_id = 0').each do |x|
      count = dashboard.objectives.find(:all, :conditions => "parent_id = #{x.id}").size
      row_num = count if count > row_num
    end

    row_num += 1

    objectives = Array.new(col_num)
    objectives.map! { Array.new(row_num) }
    dashboard.objectives.find(:all, :conditions => 'parent_id = 0', :order => 'sequence').each_with_index do |x, x_index|
      objectives[x_index][0] = x
      dashboard.objectives.find(:all, :conditions => "parent_id = #{x.id}", :order => 'sequence').each_with_index do |y, y_index|
        objectives[x_index][1 + y_index] = y
      end
    end
    formatted_objectives= Array.new(row_num)
    formatted_objectives.map! { Array.new(col_num) }
    objectives.each_with_index do |x, x_index|
      x.each_with_index do |y, y_index|
        formatted_objectives[y_index][x_index] = objectives[x_index][y_index]
      end
    end
    formatted_objectives
  end

end

class ObjectivesController < ApplicationController
  unloadable

  helper DashboardsHelper

  before_filter :init_params, :authorize, :except => [:update, :create]

  audit Objective

  def new
    @objective = Objective.new(
      :dashboard_id => @dashboard.id,
      :parent_id => params[:parent_id])

    if params[:continue]
      old_objective = Objective.find(params[:continue])
      @objective.parent_id = old_objective.parent_id
    end

    @objective.sequence = @objective.next_sequence
    @objective.risk_rating ||= 'U'

    render :update do |page|
      page.replace_html(
        'objective_edit_area',
        :partial => 'edit'
      )
      page.show 'objective_edit_area'
    end
  end

  def create
    @objective = Objective.new(params[:objective])
    render :update do |page|
      if @objective.save
        flash[:notice] = 'New objective created successfully'
        page.hide 'objective_edit_area'
        if @objective.parent_id
          if @objective.parent_id == 0
            page.insert_html :bottom, 'sortable_a',
              :partial => 'objective',
              :locals => { :o => @objective, :end_reached => false }
          elsif @objective.parent.parent_id == 0
            page.insert_html :bottom, 'sortable_b',
              :partial => 'objective',
              :locals => { :o => @objective, :end_reached => false }
          else
            page.insert_html :bottom, 'sortable_c',
              :partial => 'objective',
              :locals => { :o => @objective, :end_reached => true }
          end
        else
          page.insert_html :bottom, 'unassigned',
            :partial => 'unassigned_objective',
            :locals => { :o => @objective }
        end
      else
        page.replace_html 'objective_edit_area', :partial => 'edit'
      end
    end
  end

  def edit
    @objective = Objective.find(params[:id])
    @parents = [['Top level', 0]] if @objective.parent_id == 0
    render :update do |page|
      page.replace_html(
        'objective_edit_area',
        :partial => 'edit'
      )
      page.show 'objective_edit_area'
    end
  end

  def update
    @objective = Objective.find(params[:id])

    render :update do |page|
      if @objective.update_attributes(params[:objective])
        flash[:notice] = 'Objective updated successfully'
        page.hide 'objective_edit_area'
        page.replace_html "objective_#{@objective.id}_name", @objective.name
        page.replace_html "objective_#{@objective.id}_description", "<br />#{@objective.description}" if @objective.parent_id == 0
      else
        page.replace_html 'objective_edit_area', :partial => 'edit'
      end
    end
  end

  def destroy
    @objective = Objective.find(params[:id])
    @parent = @objective.parent
    @parent_id = @objective.parent_id
    render :update do |page|
      if @objective.destroy
        flash[:notice] = 'Objective deleted successfully'
        page.hide 'objective_edit_area'
        page.remove "objectives_#{params[:id]}"
        if @parent_id == 0
          page.replace_html 'sortable_b', ''
          page.replace_html 'sortable_c', ''
        elsif @parent and @parent.parent_id == 0
          page.replace_html 'sortable_c', ''
        end
      else
        page.replace_html 'objective_edit_area', :partial => 'edit'
      end
    end
  end

  def history
    @objectives = @dashboard.objectives
    render :partial => 'all_objectives_history'
  end

  def issues
    @query = Query.new(:name => "_")
    @query.project = @project
    unless params[:objective_id] == 'none'
      @query.add_filter("objective_id", '=', [params[:objective_id]])
    else
      @query.add_filter("objective_id", '!*', ['']) # None
      @query.add_filter("status_id", '*', ['']) # All statuses
    end

    session[:query] = {:project_id => @query.project_id, :filters => @query.filters}

    redirect_to :controller => 'issues', :action => 'index', :project_id => @project.id
  end

  protected

  def current_user
    @user ||= User.current
  end

  private

  def init_params
    @dashboard = Dashboard.find(params[:dashboard_id])
    @project = Project.find(@dashboard.project_id)
    @parents = Objective.find(:all,
                              :order => 'sequence',
                              :conditions => "parent_id > 0 and dashboard_id = #{@dashboard.id}").map { |da| ["#{da.sequence} #{da.name}", da.id] }
  end
end

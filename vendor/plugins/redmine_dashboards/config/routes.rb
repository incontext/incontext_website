ActionController::Routing::Routes.draw do |map|
  map.connect '/dashboards/sort', :controller => 'dashboards', :action => 'sort'
  map.connect '/dashboards/edit_objectives', :controller => 'dashboards', :action => 'edit_objectives'
  map.connect '/dashboards/update_category', :controller => 'dashboards', :action => 'update_category'
  map.connect '/objectives/issues', :controller => 'objectives', :action => 'issues'

  map.resources :dashboards do |dashboard|
    dashboard.resources :objectives
  end

  map.resources :dashboards
  map.resources :objectives
end

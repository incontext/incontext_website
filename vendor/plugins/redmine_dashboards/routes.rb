
connect '/dashboards/sort', :controller => 'dashboards', :action => 'sort'
connect '/dashboards/edit_objectives', :controller => 'dashboards', :action => 'edit_objectives'
connect '/dashboards/update_category', :controller => 'dashboards', :action => 'update_category'
connect '/objectives/issues', :controller => 'objectives', :action => 'issues'

resources :dashboards do |dashboard|
  dashboard.resources :objectives
end

resources :dashboards
resources :objectives

role :app, "limmen"
role :web, "limmen"
role :db,  "limmen", :primary => true

set :rails_env, "production"
set :user, "incontext"
set :deploy_to, "/var/lib/rails/incontext/#{project_name}"

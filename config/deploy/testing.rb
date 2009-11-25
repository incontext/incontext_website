role :app, "glycine"
role :web, "glycine"
role :db,  "glycine", :primary => true

set :rails_env, "testing"
set :user, "incontext"
set :deploy_to, "/var/lib/rails/incontext/#{project_name}"

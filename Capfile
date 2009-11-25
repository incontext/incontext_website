load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
Dir['lib/cap/*.rb'].each { |plugin| require plugin }

require 'capistrano/ext/multistage'
require 'mongrel_cluster/recipes'

set :project_name, "incontext_website"
set :stages, %w(production testing)
set :default_stage, "testing"

# You shouldn't need to change anything below here.
set :use_sudo, false

ssh_options[:forward_agent] = true

set :scm, :git
set :repository, "git://github.com/incontext/incontext_website.git"
set :deploy_via, :remote_cache

set :application, project_name

# Make sure the branch name is spcified
before "deploy:update", 'check_branch_name'

# Configure mongrel
# after "deploy:update", 'mongrel:cluster:configure'

after "deploy:update", 'thin_config'
after "deploy:update", 'session_store'

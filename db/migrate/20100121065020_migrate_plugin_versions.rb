class MigratePluginVersions < ActiveRecord::Migration
  def self.up
    execute "
      insert into schema_migrations values ('1-redmine_dashboards');
      insert into schema_migrations values ('2-redmine_dashboards');
      insert into schema_migrations values ('3-redmine_dashboards');
      insert into schema_migrations values ('4-redmine_dashboards');
      insert into schema_migrations values ('5-redmine_dashboards');
      insert into schema_migrations values ('6-redmine_dashboards');
      insert into schema_migrations values ('7-redmine_dashboards');

      insert into schema_migrations values ('1-redmine_wiki_extensions');
      insert into schema_migrations values ('2-redmine_wiki_extensions');
      insert into schema_migrations values ('3-redmine_wiki_extensions');
    "
  end

  def self.down
  end
end

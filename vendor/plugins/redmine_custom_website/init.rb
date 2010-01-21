require 'redmine'
require 'dispatcher'

require 'user'
require 'website_application_hooks'
require 'website_welcome_controller_patch'

Dispatcher.to_prepare do
  WelcomeController.send(:include, WebsiteWelcomeControllerPatch)
end

Redmine::Plugin.register :redmine_custom_website do
  name 'Redmine Custom Website plugin'
  author 'InContext'
  description 'This is a plugin for Redmine'
  version '0.0.1'
end

Redmine::MenuManager.map :project_menu do |menu|
  menu.delete :overview
  menu.delete :activity
  menu.push :overview, { :controller => 'projects', :action => 'show' }, :before => :issues,
    :if => Proc.new { |p| p.identifier != 'www' }
  menu.push :activity, { :controller => 'projects', :action => 'activity' }, :before => :issues,
    :if => Proc.new { |p| p.identifier != 'www' }

  menu.delete :wiki
  menu.push :wiki, { :controller => 'wiki', :action => 'index', :page => nil },
              :if => Proc.new { |p| p.wiki && !p.wiki.new_record? && User.current.logged? }

  menu.push :home, { :controller => 'wiki', :action => 'index', :page => nil }, :caption => :label_wiki_home, :before => :news,
              :if => Proc.new { |p| p.wiki && !p.wiki.new_record? && !User.current.logged? && p.identifier == 'www'}
end

Redmine::MenuManager.map :top_menu do |menu|
  menu.delete :projects
  menu.push :projects, { :controller => 'projects', :action => 'index' }, :caption => :label_project_plural,
    :if => Proc.new { User.current.logged? }
end


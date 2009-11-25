require_dependency 'welcome_controller'

module WebsiteWelcomeControllerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.extend InstanceMethods

    base.class_eval do
      alias_method_chain :index, :anonymous_user
    end
  end

  module InstanceMethods
    def index_with_anonymous_user
      @news = News.latest User.current
      @projects = Project.latest User.current
      redirect_to "/projects/www/wiki" if !User.current.logged? and Project.find('www')
    end
  end
end

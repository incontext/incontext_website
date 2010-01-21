require 'redmine'

class WebsiteApplicationHooks < Redmine::Hook::ViewListener
  def view_layouts_base_banner(context = {})
    begin
      f = File.open(FileUtils.pwd + '/vendor/plugins/redmine_custom_website/assets/views/banner.rhtml', 'r')
      return f.read
    rescue
      return ''
    end
  end
end


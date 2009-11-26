# Hooks to attach to the Redmine Issues.
class ObjectiveIssueHook  < Redmine::Hook::ViewListener

  # Renders the Objective name
  #
  # Context:
  # * :issue => Issue being rendered
  #
  def view_issues_show_details_bottom(context = { })
    if context[:project].module_enabled?('dashboards')
      data = "<td><b>Objective :</b></td><td>#{html_escape context[:issue].objective.name unless context[:issue].objective.nil?}</td>"
      return "<tr>#{data}<td></td></tr>"
    else
      return ''
    end
  end

  # Renders a select tag with all the Objectives
  #
  # Context:
  # * :form => Edit form
  # * :project => Current project
  #
  def view_issues_form_details_bottom(context = { })
    if context[:project].module_enabled?('dashboards') and Dashboard.find_by_project_id(context[:project])
      select = context[:form].select :objective_id,
        Dashboard.find_by_project_id(context[:project]).objectives.all(
          :order => 'name').sort {|x, y| x.ancestors_path <=> y.ancestors_path}.collect { |d| ["#{d.ancestors_path} #{d.name}", d.id] },
        :include_blank => true
      return "<p>#{select}</p>"
    else
      return ''
    end
  end

  # Renders a select tag with all the Deliverables for the bulk edit page
  #
  # Context:
  # * :project => Current project
  #
  def view_issues_bulk_edit_details_bottom(context = { })
    if context[:project].module_enabled?('dashboards') and Dashboard.find_by_project_id(context[:project].id)
      select = select_tag('objective_id',
                 content_tag('option', l(:label_no_change_option), :value => '') +
                 content_tag('option', l(:label_none), :value => 'none') +
                 options_for_select(
                   Dashboard.find_by_project_id(context[:project].id).objectives.all(
                     :order => 'name').sort {|x, y| x.ancestors_path <=> y.ancestors_path}.collect {|v| ["#{v.ancestors_path} #{v.name}", v.id]}))

      return content_tag(:p, "<label>#{l(:field_objective)}: " + select + "</label>")
    else
      return ''
    end
  end

  # Saves the Deliverable assignment to the issue
  #
  # Context:
  # * :issue => Issue being saved
  # * :params => HTML parameters
  #
  def controller_issues_bulk_edit_before_save(context = { })
    case true

    when context[:params][:objective_id].blank?
      # Do nothing
    when context[:params][:objective_id] == 'none'
      # Unassign objective
      context[:issue].objective = nil
    else
      context[:issue].objective = Objective.find(context[:params][:objective_id])
    end

    return ''
  end

  # Deliverable changes for the journal use the Deliverable name
  # instead of the id
  #
  # Context:
  # * :detail => Detail about the journal change
  #
  def helper_issues_show_detail_after_setting(context = { })
    # TODO Later: Overwritting the caller is bad juju
    #if context[:detail].prop_key == 'objective_id'
    #  d = Objective.find_by_name(context[:detail].value)
    #  context[:detail].value = d.name unless d.nil? || d.name.nil?

    #  d = Objective.find_by_name(context[:detail].old_value) if context[:detail].old_value
    #  context[:detail].old_value = d.name unless d.nil? || d.name.nil?
    #end
    #''
  end
end

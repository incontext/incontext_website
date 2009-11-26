require_dependency 'query'

# Patches Redmine's Queries dynamically, adding the Deliverable
# to the available query columns
module QueryObjectivePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      base.add_available_column(QueryColumn.new(:objective_name, :sortable => "#{Objective.table_name}.name"))

      alias_method_chain :available_filters, :dashboard_filters
    end

  end

  module ClassMethods

    # Setter for +available_columns+ that isn't provided by the core.
    def available_columns=(v)
      self.available_columns = (v)
    end

    # Method to add a column to the +available_columns+ that isn't provided by the core.
    def add_available_column(column)
      self.available_columns << (column)
    end
  end

  module InstanceMethods

    # Wrapper around the +available_filters+ to add a new Deliverable filter
    def available_filters_with_dashboard_filters
      available_filters = available_filters_without_dashboard_filters

      dashboard = Dashboard.find(:first, :conditions => ["project_id IN (?)", project], :order => 'name ASC')
      if project and dashboard
        objective_filters = { "objective_id" => { :type => :list_optional, :order => 14,
            :values => dashboard.objectives.all(:order => 'name').collect { |o| [o.name, o.id.to_s]}
          }}
      else
        objective_filters = { }
      end
      return available_filters.merge(objective_filters)
    end
  end
end



require_dependency 'issue'

# Copy from budget plugin file shamelessly
# Patches Redmine's Issues dynamically.  Adds a relationship
# Issue +belongs_to+ to Deliverable
module IssueObjectivePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :objective
    end

  end

  module ClassMethods
  end

  module InstanceMethods
    # Wraps the association to get the Deliverable subject.  Needed for the
    # Query and filtering
    def objective_name
      unless self.objective.nil?
        return self.objective.name
      end
    end
  end
end



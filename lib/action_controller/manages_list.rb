# adds controller methods for moving stuff up and down with acts_as_list
class ActionController::Base
  # From controller name
  #   manages_list
  # Using model
  #   manages_list ContentPart
  # Using model name
  #   manages_list 'ContentPart'
  # Using local variables from controller
  #   manages_list lambda{|controller|
  #     controller.instance_variable_get("@content_assembly").content_parts
  #   }
  def self.manages_list(start_of_association_chain = nil)
    class_eval do
      class_inheritable_accessor :manages_list_start_of_association_chain, :instance_writer => false
      include InstanceMethods
    end

    self.manages_list_start_of_association_chain = case start_of_association_chain.class.name
      when 'String'
        lambda{|controller| start_of_association_chain.constantize }
      when 'Class'
        lambda{|controller| start_of_association_chain }
      when 'NilClass'
        lambda{|controller| self.name.gsub(/Controller/, '').singularize.constantize }
      else
        self.manages_list_start_of_association_chain = start_of_association_chain
    end
  end
end

module ActionController
  module ManagesList
    module InstanceMethods
      def move_up(&block)
        @object = self.class.manages_list_start_of_association_chain.call(self).find(params[:id])
        @object.move_higher
        redirect_to :back
      end

      def move_down(&block)
        @object = self.class.manages_list_start_of_association_chain.call(self).find(params[:id])
        @object.move_lower
        redirect_to :back
      end
    end
  end
end


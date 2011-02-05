module AttributeCop
  module ActiveRecord
    module InstanceMethods
      def required?(attr_name)
        self.class.required?(attr_name, self)
      end
    end

    module ClassMethods
      def validates_presence_of_with_attribute_cop(*attr_names)
        required_attributes! *attr_names
        validates_presence_of_without_attribute_cop(*attr_names)
      end

      def required?(attr_name, instance)
        return false unless required_attributes.has_key? attr_name
        options = required_attributes[attr_name]
        if options[:if]
          options[:if].is_a?(Proc) ? instance.instance_eval(&options[:if]) : instance.send(options[:if])
        elsif options[:unless]
          !(options[:unless].is_a?(Proc) ? instance.instance_eval(&options[:unless]) : instance.send(options[:unless]))
        else
          true
        end
      end

      def required_attributes!(*attr_names)
        options = attr_names.extract_options!
        @required_attributes ||={}
        attr_names.each do |attribute|
          @required_attributes[attribute] = options
        end
      end

      def required_attributes
        @required_attributes || {}
      end

      def self.extended(base)
        mc = class << base; self; end
        mc.class_eval do
          alias_method 'validates_presence_of_without_attribute_cop', 'validates_presence_of'
          alias_method 'validates_presence_of', 'validates_presence_of_with_attribute_cop'
        end
      end
    end
  end

  module FormBuilder
    def label_with_attribute_cop(method, text = nil, options = {})
      required = options.delete(:required)
      if required || object && object.respond_to?(:required?) && object.required?(method) && required != false
        options[:class] = options[:class] ? options[:class] + ' required' : 'required'
      end

      label_without_attribute_cop(method, text, options)
    end

    def self.included(base)
      base.class_eval do
        alias_method 'label_without_attribute_cop', 'label'
        alias_method 'label', 'label_with_attribute_cop'
      end
    end
  end
end

ActiveRecord::Base.send(:include, AttributeCop::ActiveRecord::InstanceMethods)
ActiveRecord::Base.send(:extend, AttributeCop::ActiveRecord::ClassMethods)
ActionView::Helpers::FormBuilder.send(:include, AttributeCop::FormBuilder)

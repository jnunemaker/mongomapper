# encoding: UTF-8
module MongoMapper
  module Plugins
    module Clone
      extend ActiveSupport::Concern

      def initialize_copy(other)
        @_new       = true
        @_destroyed = false
        @_id        = nil
        remove_instance_variable(:"@_read__id") if instance_variable_defined? (:"@_read__id")
        associations.each do |name, association|
          instance_variable_set(association.ivar, nil)
        end
        self.attributes = other.attributes.clone.except(:_id).inject({}) do |hash, entry|
          key, value = entry
          hash[key] = value.duplicable? ? value.clone : value
          hash
        end
      end
    end
  end
end
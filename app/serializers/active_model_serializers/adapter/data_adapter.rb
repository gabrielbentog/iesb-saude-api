module ActiveModelSerializers
  module Adapter
    class DataAdapter < Attributes
      def serializable_hash(options = nil)
        hash = super
        { data: hash, meta: instance_options[:meta] }.compact
      end
    end
  end
end

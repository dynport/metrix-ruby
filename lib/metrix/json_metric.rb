require "metrix/base"

module Metrix
  module JsonMetric
    def attributes
      @attributes ||= JSON.load(@raw)
    end

    def extract(attributes, prefix = nil)
      attributes.inject({}) do |hash, (k, v)|
        path = [prefix, k].compact.join(".")
        case v
        when Hash
          hash.merge!(extract(v, path))
        when Array
          v.each_with_index do |array_value, i|
            hash.merge!(extract(v, "#{path}i"))
          end
        when Numeric
          hash[path] = v
        end
        hash
      end
    end
  end
end

require "net/http"
require "json"

class Base
  attr_reader :attributes

  class << self
    def from_json(json)
      self.new(JSON.load(json))
    end

    def from_uri(uri)
      from_json(Net::HTTP.get(URI(uri)))
    end

    def ignore_metrics(*metrics)
      @ignore = [metrics].flatten
    end

    def ignore
      @ignore ||= []
    end
  end

  def initialize(attributes)
    @attributes = attributes
  end

  def metrics
    map_attributes(attributes).reject { |k, v| self.class.ignore.include?(k) }
  end

  def map_attributes(attributes, prefix = nil)
    attributes.inject({}) do |hash, (k, v)|
      path = [prefix, k].compact.join(".")
      case v
      when Hash
        hash.merge!(map_attributes(v, path))
      when Array
        v.each_with_index do |array_value, i|
          hash.merge!(map_attributes(v, "#{path}i"))
        end
      when Numeric
        hash[path] = v
      end
      hash
    end
  end
end

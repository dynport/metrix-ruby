require "metrix"

module Metrix
  class Metric
    attr_reader :key, :value, :time, :tags

    def initialize(key, value, time, tags = {})
      @key = key
      @value = value
      @time = time
      @tags = tags
    end

    def to_opentsdb
      chunks = [:put, key, time.utc.to_i, value]
      tags.merge(hostname: Metrix.hostname, database: database).each do |k, v|
        chunks << "#{k}=#{v}" if v
      end
      chunks.join(" ")
    end

    def to_graphite
      chunks = [graphite_prefix]
      chunks << "databases.#{database}" if database
      chunks << key
      "#{chunks.join(".")} #{value} #{time.utc.to_i}"
    end

    def database
      tags[:database]
    end

    def graphite_prefix
      "metrix.#{Metrix.hostname}"
    end
  end
end

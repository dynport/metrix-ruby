require "net/http"
require "json"
require "metrix/metric"

module Metrix
  class Base
    attr_reader :attributes, :time

    class << self
      def ignore_metrics(*metrics)
        @ignore = [metrics].flatten
      end

      def ignore
        @ignore ||= []
      end
    end

    def initialize(raw, time = Time.now)
      @raw = raw
      @time = time
    end

    def metrics
      unfiltered_metrics.reject { |k, v| ignore_metric?(k) }.map do |k, v|
        Metric.new("#{prefix}.#{k}", v, @time, tags)
      end
    end

    def tags
      {}
    end

    def ignore_metric?(metric)
      self.class.ignore.include?(metric)
    end

    def unfiltered_metrics
      extract(attributes)
    end
  end
end

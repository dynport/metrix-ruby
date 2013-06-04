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

      def inherited(clazz)
        subclasses << clazz
      end

      def set_prefix(prefix)
        @prefix = prefix
      end

      def prefix
        @prefix
      end

      def subclasses
        @subclasses ||= []
      end

      def ignore
        @ignore ||= []
      end

      def set_known_metrics(*metrics)
        @known_metrics = metrics.flatten
      end

      def known_metrics
        @known_metrics
      end
    end

    def initialize(raw, time = Time.now)
      @raw = raw
      @time = time
    end

    def metrics
      unfiltered_metrics.reject { |k, v| ignore_metric?(k) }.map do |k, v|
        Metric.new("#{prefix}.#{k}", v, @time, tags)
      end + tagged_metrics
    end

    def tagged_metrics
      []
    end

    def prefix
      self.class.prefix
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

    def cast_int(value)
      value.to_i if value
    end
  end
end

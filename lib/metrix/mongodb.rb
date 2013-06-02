require "metrix/json"
require "metrix/metric"

module Metrix
  class Mongodb < Json
    ignore_metrics %w(ok mem.bits pid uptime uptimeMillis uptimeEstimate)

    def prefix
      "mongodb"
    end

    DATABASE_RECORD_SET = /^recordStats\.(.*?)\.(.*)/
    DATABASE_LOCK = /^locks/

    def ignore_metric?(metric)
      metric[DATABASE_RECORD_SET] ||
      metric[DATABASE_LOCK] ||
      super
    end

    def tagged_metrics
      unfiltered_metrics.map do |k, v|
        if k.match(DATABASE_RECORD_SET)
          database = $1
          Metric.new($2, "#{prefix}.locks.#{v}", time, database: database)
        elsif k.match(DATABASE_LOCK)
          chunks = k.split(".")
          offset = 0
          offset = 1 if chunks.at(1) == "" # for "." database
          database = chunks.at(1 + offset)
          metric = chunks[(2 + offset)..-1].join(".")
          database = "." if database == ""
          Metric.new("#{prefix}.recordStats.#{metric}", v, time, database: database)
        end
      end.compact
    end
  end
end

require "metrix/base"

module Metrix
  class Df < Base
    set_prefix "df"

    MAPPING = {
      total: 1,
      used: 2,
      available: 3,
      used_perc: 4,
    }

    set_known_metrics MAPPING.keys.map(&:to_s)

    def initialize(data)
      @data = data
      @time = Time.now
    end

    def metrics
      metrics = []
      @data.scan(%r(^(/.*)/)).each do |(line)|
        chunks = line.split(/\s+/)
        disk = chunks.at(0)
        MAPPING.each do |key, idx|
          value = cast_int(chunks.at(idx))
          metrics << Metric.new("#{prefix}.#{key}", value, time, disk: disk)
        end
      end
      metrics
    end
  end
end

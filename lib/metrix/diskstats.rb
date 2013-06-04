module Metrix
  class Diskstats < Base
    MAPPING = {
      reads_completed: 0,
      reads_merged: 1,
      sectors_read: 2,
      milliseconds_rea: 3,
      writes_completed: 4,
      writes_merged: 5,
      sectors_written: 6,
      milliseconds_written: 7,
      ios_in_progress: 8,
      milliseconds_io: 9,
      weighted_milliseconds_io: 10,
    }
    set_prefix "diskstats"
    set_known_metrics MAPPING.keys.map(&:to_s)

    def initialize(data)
      @data = data
      @time = Time.now
    end

    def metrics
      @data.scan(/^\s*(\d+)\s*(\d+)\s*(.*?) (.*)/).map do |(_, _, disk, rest)|
        next if disk.start_with?("loop") || disk.start_with?("ram")
        chunks = rest.split(" ").map(&:to_i)
        metrics = []
        MAPPING.keys.each_with_index do |m, i|
          value = chunks.at(i)
          metrics << Metric.new("#{prefix}.#{m}", value, @time, disk: disk)
        end
        metrics
      end.flatten.compact
    end
  end
end

require "socket"
require "timeout"
require "benchmark"
require "metrix/tcp_reporter"

module Metrix
  class OpenTSDB < TcpReporter
    def <<(metric)
      metric.metrics.each do |m|
        Metrix.logger.debug "buffering #{m.to_opentsdb}"
        buffers << m.to_opentsdb
        flush if buffers.count >= 1000
      end
    rescue => err
      Metrix.logger.error "#{err.message} #{err.inspect}"
    end

    def serialize_metric(m)
      m.to_opentsdb
    end
  end
end

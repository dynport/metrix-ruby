require "socket"
require "metrix"

module Metrix
  class Graphite
    attr_reader :host, :port

    def initialize(host, port = 2003)
      @host = host
      @port = port
    end

    def <<(metric)
      metric.metrics.each do |m|
        logger.debug "adding #{m.to_graphite}"
        buffers << m.to_graphite
        flush if buffers.count > 90
      end
    end

    def buffers
      @buffers ||= []
    end

    def flush
      if buffers.empty?
        logger.info "nothing to send"
        return
      end
      started = Time.now
      Socket.tcp(@host, @port) do |socket|
        socket.puts(buffers.join("\n"))
      end
      logger.info "sent #{buffers.count} in %.06fs" % [Time.now - started]
      buffers.clear
    end

    def logger
      Metrix.logger
    end
  end
end

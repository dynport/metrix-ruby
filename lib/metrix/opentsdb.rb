require "socket"

module Metrix
  class OpenTSDB
    def initialize(host, port = 4242)
      @host = host
      @port = port
    end

    def <<(metric)
      metric.metrics.each do |m|
        Metrix.logger.debug "buffering #{m.to_opentsdb}"
        buffers << m.to_opentsdb
        flush if buffers.count >= 90
      end
    rescue => err
      Metrix.logger.error "#{err.message} #{err.inspect}"
    end

    def flush
      return if buffers.empty?
      Metrix.logger.info "sending #{buffers.count} to #{@host}:#{@port}"
      Socket.tcp(@host, @port) do |socket|
        socket.puts buffers.join("\n")
      end
      buffers.clear
    end

    def buffers
      @buffers ||= []
    end
  end
end

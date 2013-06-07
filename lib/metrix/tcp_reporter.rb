module Metrix
  class TcpReporter
    attr_reader :host, :port

    def initialize(host, port = 4242, window_size = nil)
      @host = host
      @port = port
      @window_size = window_size
    end

    def window_size
      @window_size || 1000
    end

    def buffers
      @buffers ||= []
    end

    def <<(metric)
      metric.metrics.each do |m|
        line = serialize_metric(m)
        Metrix.logger.debug "buffering #{line}"
        buffers << line
        flush if buffers.count >= window_size
      end
    rescue => err
      logger.error "#{err.message} #{err.inspect}"
    end

    def flush
      Timeout.timeout(1) do
        return if buffers.empty?
        cnt = buffers.count
        Metrix.logger.info "sending #{cnt} to #{@host}:#{@port}"
        ms = Benchmark.measure do
          Socket.tcp(@host, @port) do |socket|
            buffers.each do |line|
              socket.puts line
            end
            socket.flush
          end
        end
        logger.info "sent %d metrics in %.06f" % [cnt, ms.real]
      end
    ensure
      buffers.clear
    end

    def logger
      Metrix.logger
    end
  end
end

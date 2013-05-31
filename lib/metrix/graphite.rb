require "socket"

class Graphite
  def initialize(host, port = 2003)
    @host = host
    @port = port
  end

  def <<(m)
    metrics << m
    flush if metrics.count > 90
  end

  def flush
    if metrics.empty?
      logger.info "nothing to send"
      return
    end
    started = Time.now
    Socket.tcp(@host, @port) do |socket|
      metrics.each do |m|
        logger.debug "sending #{m}"
        socket.puts "metrix.#{hostname}.#{m}"
      end
    end
    logger.info "sent #{metrics.count} in %.06fs" % [Time.now - started]
    metrics.clear
  end

  def hostname
    @hostname ||= `hostname`.strip
  end

  def metrics
    @metrics ||= []
  end

  def logger
    Metrix.logger
  end
end

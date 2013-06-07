require "socket"
require "metrix"
require "metrix/tcp_reporter"

module Metrix
  class Graphite < TcpReporter
    attr_reader :host, :port

    def initialize(host, port = 2003)
      super(host, port, 100)
    end

    def window_size
      90
    end

    def serialize_metric(m)
      m.to_graphite
    end
  end
end

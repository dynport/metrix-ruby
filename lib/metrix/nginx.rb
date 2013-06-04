require "metrix/base"

module Metrix
  class Nginx < Base
    set_prefix "nginx"
    set_known_metrics %w(accepts handled requests active_connections reading writing waiting)

    def initialize(data)
      @data = data
      @time = Time.now
    end

    def active_connections
      cast_int(@data[/Active connections: (\d+)/, 1])
    end

    [:accepts, :handled, :requests].each do |name|
      define_method(name) do
        numbers[name]
      end
    end

    def extract(data = nil)
      {
        accepts: accepts,
        handled: handled,
        requests: requests,
        active_connections: active_connections,
        reading: reading,
        writing: writing,
        waiting: waiting,
      }
    end

    def reading
      cast_int(@data[/Reading: (\d+)/, 1])
    end

    def writing
      cast_int(@data[/Writing: (\d+)/, 1])
    end

    def waiting
      cast_int(@data[/Waiting: (\d+)/, 1])
    end

    def numbers
      @numbers ||= if @data.match(/server.*\n\s*(\d+) (\d+) (\d+)/)
        @numbers = { accepts: cast_int($1), handled: cast_int($2), requests: cast_int($3) }
      else
        {}
      end
    end
  end
end

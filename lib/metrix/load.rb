require "metrix/base"

module Metrix
  class Load < Base
    set_prefix "system.load"
    set_known_metrics %w(load1 load5 load15)

    def initialize(data)
      @data = data
      @time = Time.now
    end

    def extract(data)
      {
        load1: load1,
        load5: load5,
        load15: load15,
      }
    end

    def prefix
      "system.load"
    end

    def load15
      chunks.at(2).to_f
    end

    def load5
      chunks.at(1).to_f
    end

    def load1
      chunks.at(0).to_f
    end

    def chunks
      @chunks ||= @data.split(" ")
    end
  end
end

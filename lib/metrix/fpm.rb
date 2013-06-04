require "metrix/base"

module Metrix
  class FPM < Base
    def initialize(data)
      @data = data
      @time = Time.now
    end

    def prefix
      "fpm"
    end

    def extract(data)
      {
        accepted_conn: accepted_conn,
        start_since: start_since,
        accepted_conn: accepted_conn,
        listen_queue: listen_queue,
        max_listen_queue: max_listen_queue,
        listen_queue_len: listen_queue_len,
        idle_processes: idle_processes,
        active_processes: active_processes,
        total_processes: total_processes,
        max_active_processes: max_active_processes,
        max_children_reached: max_children_reached,
        slow_requests: slow_requests,
      }
    end

    {
      "accepted conn" => :accepted_conn,
      "start since" => :start_since,
      "accepted conn" => :accepted_conn,
      "listen queue" => :listen_queue,
      "max listen queue" => :max_listen_queue,
      "listen queue len" => :listen_queue_len,
      "idle processes" => :idle_processes,
      "active processes" => :active_processes,
      "total processes" => :total_processes,
      "max active processes" => :max_active_processes,
      "max children reached" => :max_children_reached,
      "slow requests" => :slow_requests,
    }.each do |from, to|
      define_method(to) do
        cast_int(@data[/^#{from}:\s*(\d+)/, 1])
      end
    end
  end
end

require "metrix/base"

module Metrix
  class System < Base
    class Cpu
      def initialize(values)
        @values = values
      end

      {
        user:     0,
        nice:     1,
        system:   2,
        idle:     3,
        iowait:   4,
        irq:      5,
        softirq:  6,
      }.each do |k, v|
        define_method(k) do
          @values.at(v)
        end
      end
    end

    def initialize(raw = File.read("/proc/stat"), time = Time.now)
      @raw = raw
      @time = time
    end

    [:processes, :procs_running, :procs_blocked, :ctxt].each do |m|
      define_method(m) do
        cast_int(@raw[/^#{m} (\d+)/, 1])
      end
    end

    def unfiltered_metrics
      {
        "processes"       => processes,
        "procs_running"   => procs_running,
        "procs_blocked"   => procs_blocked,
        "ctxt"            => ctxt,
        "cpu.user"        => cpu.user,
        "cpu.nice"        => cpu.nice,
        "cpu.system"      => cpu.system,
        "cpu.idle"        => cpu.idle,
        "cpu.iowait"      => cpu.iowait,
        "cpu.irq"         => cpu.irq,
        "cpu.softirq"     => cpu.softirq,
      }
    end

    def load1
      loadavg.split(" ").first.to_f
    end

    def loadavg
      @loadavg ||= File.read("/proc/loadavg")
    end

    def prefix
      "system"
    end

    def cpu
      Cpu.new(@raw[/^cpu (.*)/, 1].split(" ").map(&:to_i))
    end

    def cast_int(value)
      value.to_i if value
    end
  end
end

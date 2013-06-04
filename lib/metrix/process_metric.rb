require "metrix/base"

module Metrix
  class ProcessMetric < Base
    attr_reader :time
    set_known_metrics %w(minflt cminflt majflt cmajflt utime stime cutime sctime num_threads
      vsize rss
    )
    set_prefix "system.process"

    class << self
      def all
        IO.popen("find /proc -maxdepth 2 -mindepth 2 -name stat") do |io|
          io.map do |path|
            Metrix::ProcessMetric.new(File.read(path.strip))
          end
        end
      end
    end

    def name
      comm.gsub(/^\(/, "").gsub(/\)$/, "")
    end

    def chunks
      @chunks ||= @raw.split(" ").map { |c| cast_int(c) }
    end

    def tags
      {
        name:   name,
        pid:    pid,
        ppid:   ppid,
      }
    end

    def unfiltered_metrics
      {
        minflt: minflt,
        cminflt: cminflt,
        majflt: majflt,
        cmajflt: cmajflt,
        utime: utime,
        stime: stime,
        cutime: cutime,
        sctime: sctime,
        num_threads: num_threads,
        vsize: vsize,
        rss: rss,
      }
    end

    def cast_int(str)
      Integer(str) rescue str
    end

    {
      :pid => 0,
      :comm => 1,
      :state => 2,
      :ppid => 3,
      :pgrp => 4,
      :session => 5,
      :tty_nr => 6,
      :tpgid => 7,
      :flags => 8,
      :minflt => 9,
      :cminflt => 10,
      :majflt => 11,
      :cmajflt => 12,
      :utime => 13,
      :stime => 14,
      :cutime => 15,
      :sctime => 16,
      :priority => 17,
      :nice => 18,
      :num_threads => 19,
      :itrealvalue => 20,
      :starttime => 21,
      :vsize => 22,
      :rss => 23,
      :rsslim => 24,
      :startcode => 25,
      :endcode => 26,
      :startstac => 27,
      :guest_time => 42,
      :cguest_time => 43,
    }.each do |k, v|
      define_method(k) do
        chunks.at(v)
      end
    end
  end
end

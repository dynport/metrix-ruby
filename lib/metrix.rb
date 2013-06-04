require "metrix/version"

module Metrix
  class << self
    attr_writer :logger

    def logger
      return @logger if @logger
      require "logger"
      @logger ||= Logger.new(STDOUT)
    end

    def hostname
      @hostname ||= `hostname`.strip
    end

    def known_metrics
      Dir.glob(File.expand_path("../metrix/*.rb", __FILE__)).each do |path|
        require path
      end
      Base.subclasses.map do |clazz|
        raise "known_metrics not set for #{clazz}" if clazz.known_metrics.nil?
        raise "prefix not set for #{clazz}" if clazz.prefix.nil?
        clazz.known_metrics.map do |m|
          "#{clazz.prefix}.#{m}"
        end
      end.flatten.compact.sort
    end
  end
end

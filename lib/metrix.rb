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
  end
end

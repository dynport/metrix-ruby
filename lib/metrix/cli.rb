require "metrix"
require "metrix/elastic_search"
require "metrix/mongodb"
require "metrix/nginx"
require "metrix/system"
require "metrix/load"
require "metrix/fpm"
require "logger"

module Metrix
  class CLI
    attr_reader :reporter, :elastic_search_host, :mongodb_host, :interval

    def initialize(args)
      @args = args
      @system = false
      @interval = 10
      require "syslog/logger"
      Metrix.logger = Syslog::Logger.new("metrix")
    end

    def run
      opts.parse(@args)
      Metrix.logger.level = log_level
      if self.reporter.nil?
        puts "ERROR: at least one reporter must be specified"
        abort opts.to_s
      end
      cnt = -1
      started = Time.now
      while true
        begin
          cnt += 1
          now = Time.now.utc
          if elastic_search?
            fetch_metrix :elastic_search do
              reporter << Metrix::ElasticSearch.new(elastic_search_status)
            end
          end

          if mongodb?
            fetch_metrix :mongodb do
              reporter << Metrix::Mongodb.new(mongodb_status)
            end
          end

          if nginx?
            fetch_metrix :nginx do
              reporter << Metrix::Nginx.new(nginx_status)
            end
          end

          if fpm?
            fetch_metrix :fpm do
              reporter << Metrix::FPM.new(fpm_status)
            end
          end

          if system?
            fetch_metrix :system do
              reporter << Metrix::System.new(File.read("/proc/stat"))
            end
            fetch_metrix :load do
              reporter << Metrix::Load.new(File.read("/proc/loadavg"))
            end
          end

          if processes?
            fetch_metrix :processes do
              Metrix::Process.all.each do |m|
                reporter << m
              end
            end
          end
          reporter.flush
        rescue SystemExit
          exit
        rescue => err
          Metrix.logger.error "#{err.message}"
          Metrix.logger.error "#{err.backtrace.inspect}"
        ensure
          sleep_for = @interval - (Time.now - started - cnt * interval)
          if sleep_for > 0
            Metrix.logger.info "finished run in %.06f, sleeping for %.06f" % [Time.now - now, sleep_for]
            sleep sleep_for
          else
            Metrix.logger.info "not sleeping because %.06f is negative" % [sleep_for]
          end
        end
      end
    end

    def log_level
      @log_level || Logger::INFO
    end

    def processes?
      !!@processes
    end

    def elastic_search?
      !!@elastic_search
    end

    def mongodb?
      !!@mongodb
    end

    def fpm?
      !!@fpm
    end

    def nginx?
      !!@nginx
    end

    def elastic_search_status
      get_url "http://127.0.0.1:9200/_status"
    end

    def mongodb_status
      get_url "http://127.0.0.1:28017/serverStatus"
    end

    def fpm_status
      get_url "http://127.0.0.1:9001/fpm-status"
    end

    def nginx_status
      get_url "http://127.0.0.1:8000/"
    end

    def get_url(url)
      logger.info "fetching URL #{url}"
      started = Time.now
      body = Net::HTTP.get(URI(url))
      logger.info "fetched URL #{url} in %.06f" % [Time.now - started]
      body
    end

    def fetch_metrix(type)
      started = Time.now
      logger.info "fetching metrix for #{type}"
      yield
      logger.info "fetched metrix for type #{type} in %.06f" % [Time.now - started]
    rescue => err
      logger.error "#{err.message} #{err.backtrace.inspect}"
    end

    def logger
      Metrix.logger
    end

    def system?
      !!@system
    end

    def log_to_stdout
      Metrix.logger = Logger.new(STDOUT)
      Metrix.logger.level = Logger::INFO
    end

    def opts
      require "optparse"
      @opts ||= OptionParser.new do |o|
        o.on("-v", "--version") do
          puts "metrix #{Metrix::VERSION}"
          exit
        end

        o.on("--fpm") do
          @fpm = true
        end

        o.on("--nginx") do
          @nginx = true
        end

        o.on("--mongodb") do
          @mongodb = true
        end

        o.on("--elasticsearch") do
          @elastic_search = true
        end

        o.on("--graphite-host HOST") do |value|
          require "metrix/graphite"
          @reporter = Metrix::Graphite.new(value, 2003)
        end

        o.on("--opentsdb-host HOST") do |value|
          require "metrix/opentsdb"
          @reporter = Metrix::OpenTSDB.new(value, 4242)
        end

        o.on("--stdout") do
          require "metrix/reporter/stdout"
          @reporter = Metrix::Reporter::Stdout.new
          log_to_stdout
        end

        o.on("--debug") do
          @log_level = Logger::DEBUG
        end

        o.on("--no-syslog") do
          log_to_stdout
        end

        o.on("--processes") do
          require "metrix/process"
          @processes = true
        end

        o.on("--system") do
          require "metrix/system"
          @system = true
        end
      end
    end
  end
end

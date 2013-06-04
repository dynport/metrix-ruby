require "metrix"
require "metrix/elastic_search"
require "metrix/mongodb"
require "metrix/nginx"
require "metrix/system"
require "metrix/load"
require "metrix/memory"
require "metrix/fpm"
require "metrix/process_metric"
require "metrix/load"
require "logger"
require "fileutils"

module Metrix
  class CLI
    attr_reader :interval

    def initialize(args)
      @args = args
      @system = false
      @interval = 10
      require "syslog/logger"
      Metrix.logger = Syslog::Logger.new("metrix")
      Metrix.logger.level = Logger::INFO
    end

    def parse!
      @action = opts.parse(@args).first
    end

    def action
      @action ||= parse!
    end

    def run
      parse!
      case @action
      when "start"
        load_configs_from_file!
        if running?
          logger.warn "refuse to run. seems that #{pid_path} exists!"
          abort "not allowed to run" if running?
        end
        if daemonize?
          pid = Process.fork do
            start
          end
          sleep 1
          Process.detach(pid)
        else
          start
        end
      when "status"
        if File.exists?(pid_path)
          logger.debug "#{pid_path} exists"
          puts "STATUS: running with pid #{File.read(pid_path).strip}"
          exit 0
        else
          logger.debug "#{pid_path} does not exist"
          puts "STATUS: not running"
          exit 1
        end
      when "stop"
        abort "not running!" if !running?
        pid = File.read(pid_path).strip
        logger.info "killing pid #{pid}"
        system "kill #{pid}"
        puts "killed #{pid}"
      when "configtest"
        load_configs_from_file!
        puts "running configtest #{attributes.inspect}"
      when "list_metrics"
        puts Metrix.known_metrics.join("\n")
      else
        logger.warn "action #{action} unknown!"
        abort "action #{action} unknown!"
      end
    end

    def delete_pidfile!
      logger.info "deleteing pidfile #{pid_path}"
      FileUtils.rm_f(pid_path)
    end

    def start
      if self.reporter.nil?
        puts "ERROR: at least one reporter must be specified"
        abort opts.to_s
      end
      Signal.trap("TERM") do
        logger.info "terminating..."
        $running = false
      end
      $running = true
      cnt = -1
      started = Time.now
      write_pidfile!(Process.pid)
      while $running
        begin
          cnt += 1
          now = Time.now.utc
          fetch_metrix(:elasticsearch)  { reporter << Metrix::ElasticSearch.new(fetch_resource(:elasticsearch)) }
          fetch_metrix(:mongodb)        { reporter << Metrix::Mongodb.new(fetch_resource(:mongodb)) }
          fetch_metrix(:nginx)          { reporter << Metrix::Nginx.new(fetch_resource(:nginx)) }
          fetch_metrix(:fpm)            { reporter << Metrix::FPM.new(fetch_resource(:fpm)) }
          fetch_metrix(:system)         { reporter << Metrix::System.new(File.read("/proc/stat")) }
          fetch_metrix(:load)           { reporter << Metrix::Load.new(File.read("/proc/loadavg")) }
          fetch_metrix(:memory)         { reporter << Metrix::Memory.new(File.read("/proc/meminfo")) }

          fetch_metrix :processes do
            Metrix::ProcessMetric.all.each do |m|
              reporter << m
            end
          end
          reporter.flush
        rescue SystemExit
          $running = false
        rescue => err
          Metrix.logger.error "#{err.message}"
          Metrix.logger.error "#{err.backtrace.inspect}"
        ensure
          begin
            sleep_for = @interval - (Time.now - started - cnt * interval)
            if sleep_for > 0
              Metrix.logger.info "finished run in %.06f, sleeping for %.06f" % [Time.now - now, sleep_for]
              sleep sleep_for
            else
              Metrix.logger.info "not sleeping because %.06f is negative" % [sleep_for]
            end
          rescue SystemExit, Interrupt
            $running = false
          end
        end
      end
      delete_pidfile!
    end

    def reporter
      @reporter ||= if attributes[:opentsdb]
        require "metrix/opentsdb"
        uri = URI.parse(attributes[:opentsdb])
        Metrix::OpenTSDB.new(uri.host, uri.port)
      elsif attributes[:graphite]
        require "metrix/graphite"
        uri = URI.parse(attributes[:graphite])
        Metrix::Graphite.new(uri.host, uri.port)
      elsif @foreground == true
        require "metrix/reporter/stdout"
        Metrix::Reporter::Stdout.new
      end
    end

    def write_pidfile!(pid)
      logger.info "writing #{pid} to #{pid_path}"
      File.open(pid_path, "w") { |f| f.print(pid) }
    end

    def allowed_to_run?
      !running?
    end

    def pid_path
      "/var/run/metrix.pid"
    end

    def running?
      File.exists?(pid_path)
    end

    def enabled?(key)
      !!attributes[key]
    end

    def elasticsearch_status
      get_url url_for(:elasticsearch)
    end

    def fetch_resource(key)
      get_url(url_for(key))
    end

    def url_for(key)
      attributes[key]
    end

    def get_url(url)
      logger.info "fetching URL #{url}"
      started = Time.now
      body = Net::HTTP.get(URI(url))
      logger.info "fetched URL #{url} in %.06f" % [Time.now - started]
      body
    end

    def fetch_metrix(type)
      return false if !enabled?(type)
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

    def log_to_stdout
      Metrix.logger = Logger.new(STDOUT)
      Metrix.logger.level = Logger::INFO
    end

    def daemonize?
      @foreground != true
    end

    def attributes
      @attributes ||= {}
    end

    def load_configs_from_file!
      require "erb"
      require "yaml"
      hash = YAML.load(ERB.new(File.read(config_path)).result)
      @attributes = hash.inject({}) do |hash, (k, v)|
        hash[k.to_sym] = v
        hash
      end
    end

    def config_path
      @config_path || default_config_path
    end

    def default_config_path
      File.expand_path("/etc/metrix.yml")
    end

    def opts
      require "optparse"
      @opts ||= OptionParser.new do |o|
        o.on("-v", "--version") do
          puts "metrix #{Metrix::VERSION}"
          exit
        end

        o.on("-c PATH") do |value|
          @config_path = value
        end

        o.on("-d", "--debug") do |value|
          @foreground = true
          log_to_stdout
          Metrix.logger.level = Logger::DEBUG
        end
      end
    end
  end
end

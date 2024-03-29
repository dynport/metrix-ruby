#!/usr/bin/env ruby
# tags: rspec default settings wip config

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true

  c.before do
    require "metrix"
    Metrix.stub(:hostname) { "test.host" }
    Metrix.logger.level = Logger::ERROR
  end
end

def hash_metrics(metrics)
  metrics.inject({}) do |hash, m|
    hash[m.key] = m
    hash
  end
end

require "metrix/process_metric"

require "pathname"
FIXTURES_PATH = Pathname.new(File.expand_path("../fixtures", __FILE__))

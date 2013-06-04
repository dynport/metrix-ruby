require "spec_helper"
require "metrix/mongodb"

describe "Metrix::Mongodb" do
  let(:payload) { FIXTURES_PATH.join("mongo_server_status.json").read }

  subject(:status) { Metrix::Mongodb.new(payload) }
  it { should_not be_nil }

  describe "metric keys" do
    subject(:keys) { status.metrics.map(&:key) }

    %w(
      mongodb.ok mongodb.mem.bits mongodb.pid
      mongodb.uptimeMillis mongodb.uptimeEstimate
    ).each do |name|
      it "should not have key #{name.inspect}" do
        subject.should_not include(name)
      end
    end
  end

  describe "#metrics" do
    subject(:metrics) { hash_metrics(status.metrics) }
    it { should be_kind_of(Hash) }

    {
      "mongodb.globalLock.totalTime"=>474819000,
      "mongodb.globalLock.lockTime"=>1060706,
      "mongodb.globalLock.currentQueue.total"=>0,
      "mongodb.globalLock.currentQueue.readers"=>0,
      "mongodb.globalLock.currentQueue.writers"=>0,
      "mongodb.globalLock.activeClients.total"=>0,
      "mongodb.globalLock.activeClients.readers"=>0,
      "mongodb.globalLock.activeClients.writers"=>0,
      "mongodb.mem.resident"=>9,
      "mongodb.uptime"=> 475,
      "mongodb.mem.virtual"=>2814,
      "mongodb.recordStats.accessesNotInMemory" => 0,
      "mongodb.recordStats.pageFaultExceptionsThrown" => 0,
    }.each do |k, v|
      it "should set #{k} to #{v}" do
        subject[k].value.should eq(v)
      end
    end
  end
end


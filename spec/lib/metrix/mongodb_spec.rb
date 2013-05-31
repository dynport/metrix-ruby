require "spec_helper"
require "metrix/mongodb"

describe "Metrix::Mongodb", :wip do
  let(:payload) { FIXTURES_PATH.join("mongo_server_status.json").read }

  subject(:status) { Metrix::Mongodb.from_json(payload) }
  it { should_not be_nil }

  describe "#metrics" do
    subject(:metrics) { status.metrics }
    it { should be_kind_of(Hash) }

    %w(ok mem.bits pid uptime uptimeMillis uptimeEstimate).each do |name|
      it "should not have key #{name.inspect}" do
        subject.should_not have_key(name)
      end
    end

    {
      "globalLock.totalTime"=>36018171,
      "globalLock.lockTime"=>347,
      "globalLock.ratio"=>9.634026114207743e-06,
      "globalLock.currentQueue.total"=>0,
      "globalLock.currentQueue.readers"=>0,
      "globalLock.currentQueue.writers"=>0,
      "globalLock.activeClients.total"=>0,
      "globalLock.activeClients.readers"=>0,
      "globalLock.activeClients.writers"=>0,
      "mem.resident"=>14,
      "mem.virtual"=>2414,
    }.each do |k, v|
      it "should set #{k} to #{v}" do
        subject[k].should eq(v)
      end
    end
  end
end


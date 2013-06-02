require "spec_helper"
require "metrix/system"

describe "Metrix::System" do
  let(:data) {FIXTURES_PATH.join("proc.stat.txt").read }
  subject(:system) { Metrix::System.new(data) }

  it { should_not be_nil }
  it { subject.processes.should eq(28467) }
  it { subject.procs_running.should eq(1) }
  it { subject.procs_blocked.should eq(0) }

  describe "#metrics" do
    subject(:metrics) { hash_metrics(system.metrics) }

    {
      "system.processes" => 28467,
      "system.procs_running"=>1,
      "system.procs_blocked"=>0
    }.each do |k, v|
      it "should set #{k.inspect} to #{v.inspect}" do
        subject[k].value.should eq(v)
      end
    end
  end

  describe "#cpu" do
    subject(:cpu) { system.cpu }
    it { subject.user.should eq(79833) }
    it { subject.nice.should eq(8300) }
    it { subject.system.should eq(84916) }
    it { subject.idle.should eq(5887890) }
    it { subject.iowait.should eq(54619) }
    it { subject.irq.should eq(93) }
    it { subject.softirq.should eq(19796) }
  end
end


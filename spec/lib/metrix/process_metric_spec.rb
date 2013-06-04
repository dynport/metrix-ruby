require "spec_helper"
require "metrix/process_metric"

describe "Metrix::ProcessMetric" do
  let(:data) { FIXTURES_PATH.join("proc.26928.txt").read }
  subject(:process) { Metrix::ProcessMetric.new(data) }

  it { should_not be_nil }
  it { subject.time.should be_kind_of(Time) }

  it { subject.name.should eq("java") }
  it { subject.state.should eq("S") }
  it { subject.utime.should eq(32337) }
  it { subject.stime.should eq(34740) }

  describe "#metrics" do
    subject(:metrics) do
      hash_metrics(process.metrics)
    end

    it { should be_kind_of(Hash) }

    {
      "system.process.minflt"  => 332517,
      "system.process.cminflt" => 9459,
      "system.process.majflt"  => 13,
      "system.process.cmajflt" => 0,
      "system.process.utime"   => 32337,
      "system.process.stime"   => 34740,
      "system.process.cutime"  => 2,
      "system.process.sctime"  => 16,
      "system.process.num_threads" => 125,
      "system.process.vsize" => 1688936448,
      "system.process.rss" => 289510,
    }.each do |k, v|
      it "should set #{k.inspect} to #{v.inspect}" do
        subject[k].value.should eq(v)
      end
    end
  end

  describe "#tags" do
    subject(:tags) { process.tags }
    it { should be_kind_of(Hash) }
    it { subject[:name].should eq("java") }
    it { subject[:pid].should eq(26928) }
    it { subject[:ppid].should eq(1) }
  end
end

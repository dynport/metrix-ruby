require "spec_helper"
require "metrix/diskstats"

describe "Metrix::Diskstats", :wip do
  let(:data) { FIXTURES_PATH.join("diskstats.txt").read }
  subject(:stats) { Metrix::Diskstats.new(data) }
  it { should_not be_nil }

  it { subject.prefix.should eq("diskstats") }

  it { Metrix::Diskstats.known_metrics.count.should eq(11) }

  describe "#metrics" do
    subject(:metrics) { stats.metrics }
    it { subject.count.should eq(22) }

    describe "first metric" do
      subject(:first) { metrics.first }
      it { should_not be_nil }
      it { subject.key.should eq("diskstats.reads_completed") }
      it { subject.value.should eq(12732) }
      it { subject.tags.should eq(disk: "sda") }
      it { subject.to_opentsdb.should include("hostname=") }
    end
  end
end

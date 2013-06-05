require "spec_helper"
require "metrix/df"

describe "Metrix::Df", :wip do
  let(:data) { FIXTURES_PATH.join("df.txt").read }
  subject(:df) { Metrix::Df.new(data) }

  it { should_not be_nil }

  it { Metrix::Df.prefix.should eq("df") }

  describe "#known_metrics" do
    subject(:known) { Metrix::Df.known_metrics }
    it { should be_kind_of(Array) }
  end

  describe "#metrics" do
    subject(:metrics) { df.metrics }
    it { should be_kind_of(Array) }
    it { subject.count.should eq(8) }

    describe "#first" do
      before do
        df.stub(:time) { Time.at(11) }
      end

      subject(:first) { metrics.first }
      it { should_not be_nil }
      it { subject.key.should eq("df.total") }
      it { subject.value.should eq(8125880) }
      it { subject.time.should eq(Time.at(11)) }
      it { subject.tags.should eq(disk: "/dev/xvda1") }
    end
  end
end


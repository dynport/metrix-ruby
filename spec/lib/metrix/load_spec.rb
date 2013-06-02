require "spec_helper"
require "metrix/load"

describe "Metrix::Load" do
  let(:data) {FIXTURES_PATH.join("loadavg.txt").read }
  subject(:loadavg) { Metrix::Load.new(data) }

  it { should_not be_nil }
  it { loadavg.load1.should eq(0.04) }
  it { loadavg.load5.should eq(0.23) }
  it { loadavg.load15.should eq(0.26) }

  describe "#metrics" do
    subject(:metrics) { loadavg.extract(1) }
    it { should be_kind_of(Hash) }
    it { subject.count.should eq(3) }

    {
      load1:  0.04,
      load5:  0.23,
      load15: 0.26,
    }.each do |k, v|
      it "should return #{k.inspect} with #{v.inspect}" do
        subject[k].should eq(v)
      end
    end
  end
end


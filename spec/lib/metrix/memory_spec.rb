require "spec_helper"
require "metrix/memory"

describe "Metrix::Memory" do
  let(:data) { FIXTURES_PATH.join("memory.txt").read }
  subject(:memory) { Metrix::Memory.new(data) }
  it { should_not be_nil }

  it { memory.prefix.should eq("memory") }

  it { subject.mem_total.should eq(4049980) }
  it { subject.mem_free.should eq(3614536) }
  it { subject.active_anon.should eq(21128) }

  it { Metrix::Memory.known_metrics.should be_kind_of(Array) }

  it { subject.metrics.count.should eq(42) }

  describe "first value" do
    subject(:first) { memory.metrics.first }

    it { subject.key.should eq("memory.mem_total") }
    it { subject.value.should eq(4049980) }
  end
end

require "spec_helper"
require "metrix/graphite"

describe "Metrix::Graphite" do
  let(:data) { FIXTURES_PATH.join("proc.26928.txt").read }
  let(:metric) { Metrix::Process.new(data, Time.at(1370091027)) }
  subject(:client) { Metrix::Graphite.new("128.0.0.1") }

  it { should_not be_nil }
  it { subject.port.should eq(2003) }

  describe "#<<" do
    before do
      client << metric
    end

    it { should_not be_nil }
    it { client.buffers.count.should eq(11) }
    describe "first line" do
      subject(:line) { client.buffers.first }
      it { should eq("metrix.test.host.system.process.minflt 332517 1370091027") }
    end
  end
end


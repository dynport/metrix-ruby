require "spec_helper"
require "metrix/opentsdb"

describe "Metrix::OpenTSDB" do
  let(:data) { FIXTURES_PATH.join("proc.26928.txt").read }
  subject(:client) { Metrix::OpenTSDB.new("127.0.0.1", 1234) }
  let(:metric) { Metrix::Process.new(data) }

  it { should_not be_nil }

  describe "adding a metric" do
    before do
      client << metric
    end

    it { should_not be_nil }
    it { subject.buffers.count.should eq(11) }

    describe "first in buffer" do
      subject(:line) { client.buffers.first }
      it { should be_kind_of(String) }
      it { should include("pid=26928") }
      it { should include("332517 name=java") }
    end
  end
end


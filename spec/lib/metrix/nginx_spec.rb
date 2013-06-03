require "spec_helper"
require "metrix/nginx"

describe "Metrix::Nginx" do
  subject(:nginx) { Metrix::Nginx.new(FIXTURES_PATH.join("nginx.status.txt").read) }
  it { should_not be_nil }

  it { subject.active_connections.should eq(1) }
  it { subject.accepts.should eq(7) }
  it { subject.handled.should eq(8) }
  it { subject.requests.should eq(11) }

  it { subject.reading.should eq(0) }
  it { subject.writing.should eq(1) }
  it { subject.waiting.should eq(3) }

  it { subject.prefix.should eq("nginx") }

  describe "#extract" do
    subject(:extracted) { nginx.extract(nil) }
    it { should be_kind_of(Hash) }
    it { subject[:accepts].should eq(7) }
    it { subject[:active_connections].should eq(1) }
  end
end

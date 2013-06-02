require "spec_helper"
require "metrix/metric"

describe "Metrix::Metric" do
  subject(:metric) do
    Metrix::Metric.new("recordStats.pageFaultExceptionsThrown", 10, Time.at(12), database: "opentsdb")
  end

  it { should_not be_nil }

  describe "#to_graphite" do
    subject(:string) { metric.to_graphite }
    it { should be_kind_of(String) }
    it { should eq("metrix.test.host.databases.opentsdb.recordStats.pageFaultExceptionsThrown 10 12") }
  end

  describe "#to_opentsdb" do
    subject(:string) { metric.to_opentsdb }
    it { should be_kind_of(String) }
    it { should eq("put recordStats.pageFaultExceptionsThrown 12 10 database=opentsdb hostname=test.host") }
  end
end


require "spec_helper"

describe "Metrix" do
  subject(:metrix) { Metrix }
  it { should_not be_nil }

  describe "#known_metrics" do
    subject(:known_metrics) { Metrix.known_metrics }
    it { should be_kind_of(Array) }
    it { should_not be_empty }
    it { subject.count.should > 170 }

    it { should include("mongodb.uptime") }
  end
end


require "spec_helper"
require "metrix/fpm"

describe "Metrix::FPM", :wip do
  let(:data) { FIXTURES_PATH.join("php.fpm.status.txt").read }
  subject(:fpm) { Metrix::FPM.new(data) }
  it { should_not be_nil }
  it { subject.start_since.should eq(29) }
  it { subject.accepted_conn.should eq(4) }
  it { subject.listen_queue.should eq(1) }
  it { subject.idle_processes.should eq(1) }

  it { subject.prefix.should eq("fpm") }

  describe "#extract" do
    subject(:extract) { fpm.extract(1) }
    it { should be_kind_of(Hash) }
    it { subject[:accepted_conn].should eq(4) }
    it { subject[:active_processes].should eq(2) }
  end
end


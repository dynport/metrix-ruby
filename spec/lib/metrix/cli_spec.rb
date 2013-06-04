require "spec_helper"
require "metrix/cli"

describe "Metrix::CLI", :wip do
  subject(:cli) { Metrix::CLI.new([]) }
  it { should_not be_nil }

  it { cli.pid_path.should eq("/var/run/metrix.pid") }

  describe "#running?" do
    before do
      File.stub(:exists?).with("/var/run/metrix.pid") { false }
    end
    it { cli.should_not be_running }

    describe "being running" do
      before do
        File.stub(:exists?).with("/var/run/metrix.pid") { true }
      end
      it { cli.should be_running }
    end
  end

  describe "#allowed_to_run?" do
    before do
      cli.stub(:running?) { true }
    end

    it { should_not be_allowed_to_run }
  end
end

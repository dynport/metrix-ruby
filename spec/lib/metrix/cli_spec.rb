require "spec_helper"
require "metrix/cli"

describe "Metrix::CLI" do
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

  describe "with graphite reporter" do
    subject(:reporter) do
      cli.attributes[:graphite] = "tcp://123.3.4.5:1212"
      cli.reporter
    end

    it { should_not be_nil }
    it { subject.host.should eq("123.3.4.5") }
    it { subject.port.should eq(1212) }
  end

  describe "initializing from config file" do
    let(:path) { FIXTURES_PATH.join("metrix.yml").to_s }
    subject(:cli) { Metrix::CLI.new(["-c", path, "configtest"]) }

    before do
      cli.stub(:puts)
      cli.run
    end

    it { cli.config_path.should eq(path) }
    it { should_not be_nil }
    it { should be_enabled(:system) }
    it { should be_enabled(:load) }
    it { should be_enabled(:processes) }
    it { subject.reporter.should be_kind_of(Metrix::OpenTSDB) }
    it { subject.attributes[:opentsdb].should include("some.host") }
    it { subject.should_not be_enabled(:elasticsearch) }
    it { subject.url_for(:fpm).should_not be_nil }
    it { subject.should be_enabled(:fpm) }
    it { subject.should_not be_enabled(:mongodb) }
    it { subject.should be_daemonize }

    describe "#reporter" do
      subject(:reporter) { cli.reporter }
      it { should_not be_nil }
      it { subject.host.should eq("some.host") }
    end
  end

  describe "with no parameters called" do
    subject(:cli) { Metrix::CLI.new([]) }
    it { should_not be_nil }
    it { cli.config_path.should eq("/etc/metrix.yml") }
  end

  describe "running in forground" do
    subject(:cli) { Metrix::CLI.new(["--debug"]) }
    before do
      cli.parse!
    end
    it { should_not be_nil }
    it { subject.reporter.should_not be_nil }
    it { cli.config_path.should eq("/etc/metrix.yml") }
  end
end

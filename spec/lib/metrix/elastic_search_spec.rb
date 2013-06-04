require "spec_helper"
require "metrix/elastic_search"

describe "Metrix::ElasticSearch" do
  let(:payload) { FIXTURES_PATH.join("es_status.json").read }
  subject(:es_status) { Metrix::ElasticSearch.new(payload) }
  it { should_not be_nil }
  it { subject.attributes.should be_kind_of(Hash) }
  it { subject.time.should_not be_nil }

  describe "#metrics" do
    subject(:extracted) { hash_metrics(es_status.metrics) }

    it { should be_kind_of(Hash) }
    it { should_not be_empty }

    {
      "elasticsearch._shards.total"=>10,
      "elasticsearch._shards.successful"=>5,
      "elasticsearch._shards.failed"=>0,
    }.each do |k, v|
      it "should set attributes #{k.inspect} to #{v.inspect}" do
        subject[k].value.should eq(v)
      end
    end

    it { should_not include("elasticsearch.indices.search.flush.total") }
    it { subject.keys.count.should eq(20) }
  end

  it { subject.unfiltered_metrics.should include("indices.search.flush.total") }

  describe "#metrics" do
    subject(:tagged_metrics) { es_status.metrics }
    it { should be_kind_of(Array) }
    it { should_not be_empty }

    it { subject.count.should eq(20) }

    describe "first metric" do

      before :each do
        es_status.stub(:time) { Time.at(10) }
      end

      subject(:first) { tagged_metrics.select { |m| m.key == "elasticsearch.index.primary_size_in_bytes" }.first }
      it { should_not be_nil }
      it { subject.key.should start_with("elasticsearch.index.primary_size_in_bytes") }
      it { subject.value.should eq(2008) }
      it { subject.time.should_not be_nil }
      it { subject.tags.should eq(index: "search") }
      it { subject.to_opentsdb.should eq("put elasticsearch.index.primary_size_in_bytes 10 2008 index=search hostname=test.host") }
    end
  end
end

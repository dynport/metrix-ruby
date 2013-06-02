require "spec_helper"
require "metrix/elastic_search"

describe "Metrox::ElasticSearch" do
  let(:payload) { FIXTURES_PATH.join("es_status.json").read }
  subject(:es_status) { Metrix::ElasticSearch.new(payload) }
  it { should_not be_nil }
  it { subject.attributes.should be_kind_of(Hash) }
  it { subject.time.should_not be_nil }

  describe "#metrics" do
    subject(:metrics) { hash_metrics(es_status.metrics) }
    it { should be_kind_of(Hash) }
    it { should_not be_empty }

    {
      "elasticsearch._shards.total"=>10,
      "elasticsearch._shards.successful"=>5,
      "elasticsearch._shards.failed"=>0,
      "elasticsearch.indices.search.index.primary_size_in_bytes"=>2008,
      "elasticsearch.indices.search.index.size_in_bytes"=>2008,
      "elasticsearch.indices.search.translog.operations"=>1,
      "elasticsearch.indices.search.docs.num_docs"=>1,
      "elasticsearch.indices.search.docs.max_doc"=>1,
      "elasticsearch.indices.search.docs.deleted_docs"=>0,
      "elasticsearch.indices.search.merges.current"=>0,
      "elasticsearch.indices.search.merges.current_docs"=>0,
      "elasticsearch.indices.search.merges.current_size_in_bytes"=>0,
      "elasticsearch.indices.search.merges.total"=>0,
      "elasticsearch.indices.search.merges.total_time_in_millis"=>0,
      "elasticsearch.indices.search.merges.total_docs"=>0,
      "elasticsearch.indices.search.merges.total_size_in_bytes"=>0,
      "elasticsearch.indices.search.refresh.total"=>6,
      "elasticsearch.indices.search.refresh.total_time_in_millis"=>124,
      "elasticsearch.indices.search.flush.total"=>0,
    }.each do |k, v|
      it "should set attributes #{k.inspect} to #{v.inspect}" do
        subject[k].value.should eq(v)
      end
    end
    it { subject.keys.count.should eq(20) }
  end
end

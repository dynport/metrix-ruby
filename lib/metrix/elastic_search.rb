require "metrix/json_metric"

module Metrix
  class ElasticSearch < Base
    include JsonMetric
    set_prefix "elasticsearch"
    set_known_metrics %w(
      _shards.total _shards.successful _shards.failed index.primary_size_in_bytes
      index.size_in_bytes translog.operations docs.num_docs docs.max_doc
      docs.deleted_docs merges.current merges.current_docs merges.current_size_in_bytes
      merges.total merges.total_time_in_millis merges.total_docs
      merges.total_size_in_bytes refresh.total refresh.total_time_in_millis flush.total
      flush.total_time_in_millis
    )

    DATABASE_INDEX = /^indices\./
    def metrics
      unfiltered_metrics.map do |k, v|
        if k.match(DATABASE_INDEX)
          _, index_name, key = k.split(".", 3)
          Metric.new("#{prefix}.#{key}", v, time, index: index_name)
        else
          Metric.new("#{prefix}.#{k}", v, time)
        end
      end.compact
    end
  end
end

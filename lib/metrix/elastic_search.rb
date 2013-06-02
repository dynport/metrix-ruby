require "metrix/json"

module Metrix
  class ElasticSearch < Json
    ignore_metrics []

    def prefix
      "elasticsearch"
    end
  end
end

require "metrix/base"

module Metrix
  class Mongodb < Base
    ignore_metrics %w(ok mem.bits pid uptime uptimeMillis uptimeEstimate)
  end
end

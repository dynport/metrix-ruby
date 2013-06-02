module Metrix
  module Reporter
    class Stdout
      def initialize
      end

      def <<(metric)
        metric.metrics.each do |m|
          Metrix.logger.info "#{m.key} #{m.value} #{m.tags.inspect}"
        end
      end

      def flush
      end
    end
  end
end

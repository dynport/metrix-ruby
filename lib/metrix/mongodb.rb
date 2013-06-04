require "metrix/json_metric"
require "metrix/metric"

module Metrix
  class Mongodb < Base
    include JsonMetric
    set_prefix "mongodb"
    set_known_metrics %w(
      asserts.msg asserts.regular asserts.rollovers asserts.user asserts.warning backgroundFlushing.average_ms
      backgroundFlushing.flushes backgroundFlushing.last_ms backgroundFlushing.total_ms connections.available connections.current
      connections.totalCreated cursors.clientCursors_size cursors.timedOut cursors.totalOpen dur.commits dur.commitsInWriteLock
      dur.compression dur.earlyCommits dur.journaledMB dur.timeMs.dt dur.timeMs.prepLogBuffer dur.timeMs.remapPrivateView
      dur.timeMs.writeToDataFiles dur.timeMs.writeToJournal dur.writeToDataFilesMB extra_info.page_faults globalLock.activeClients.readers
      globalLock.activeClients.total globalLock.activeClients.writers globalLock.currentQueue.readers globalLock.currentQueue.total
      globalLock.currentQueue.writers globalLock.lockTime globalLock.totalTime indexCounters.accesses indexCounters.hits
      indexCounters.missRatio indexCounters.misses indexCounters.resets mem.mapped mem.mappedWithJournal mem.resident mem.virtual
      metrics.document.deleted metrics.document.inserted metrics.document.returned metrics.document.updated metrics.getLastError.wtime.num
      metrics.getLastError.wtime.totalMillis metrics.getLastError.wtimeouts metrics.operation.fastmod metrics.operation.idhack
      metrics.operation.scanAndOrder metrics.queryExecutor.scanned metrics.record.moves metrics.repl.apply.batches.num
      metrics.repl.apply.batches.totalMillis metrics.repl.apply.ops metrics.repl.buffer.count metrics.repl.buffer.maxSizeBytes
      metrics.repl.buffer.sizeBytes metrics.repl.network.bytes metrics.repl.network.getmores.num metrics.repl.network.getmores.totalMillis
      metrics.repl.network.ops metrics.repl.network.readersCreated metrics.repl.oplog.insert.num metrics.repl.oplog.insert.totalMillis
      metrics.repl.oplog.insertBytes metrics.repl.preload.docs.num metrics.repl.preload.docs.totalMillis metrics.repl.preload.indexes.num
      metrics.repl.preload.indexes.totalMillis metrics.ttl.deletedDocuments metrics.ttl.passes network.bytesIn network.bytesOut
      network.numRequests opcounters.command opcounters.delete opcounters.getmore opcounters.insert opcounters.query
      opcounters.update opcountersRepl.command opcountersRepl.delete opcountersRepl.getmore opcountersRepl.insert opcountersRepl.query
      opcountersRepl.update recordStats.accessesNotInMemory recordStats.pageFaultExceptionsThrown recordStats.timeAcquiringMicros.R
      recordStats.timeAcquiringMicros.W recordStats.timeAcquiringMicros.r recordStats.timeAcquiringMicros.r recordStats.timeAcquiringMicros.w
      recordStats.timeAcquiringMicros.w recordStats.timeLockedMicros.R recordStats.timeLockedMicros.W recordStats.timeLockedMicros.r
      recordStats.timeLockedMicros.r recordStats.timeLockedMicros.w recordStats.timeLockedMicros.w uptime
    )

    DATABASE_RECORD_SET = /^recordStats\.(.*?)\.(.*)/
    DATABASE_LOCK = /^locks/

    def metrics
      unfiltered_metrics.map do |k, v|
        next unless self.class.known_metrics.include?(k)
        if k.match(DATABASE_RECORD_SET)
          next if %w(accessesNotInMemory pageFaultExceptionsThrown).include?($2)
          database = $1
          Metric.new("#{prefix}.#{$2}", v, time, database: database)
        elsif k.match(DATABASE_LOCK)
          chunks = k.split(".")
          offset = 0
          offset = 1 if chunks.at(1) == "" # for "." database
          database = chunks.at(1 + offset)
          metric = chunks[(2 + offset)..-1].join(".")
          database = "." if database == ""
          Metric.new("#{prefix}.recordStats.#{metric}", v, time, database: database)
        else
          Metric.new("#{prefix}.#{k}", v, time)
        end
      end.compact
    end
  end
end

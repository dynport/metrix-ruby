require "metrix/base"

module Metrix
  class Memory < Base
    set_prefix "memory"

    def initialize(data)
      @data = data
      @time = Time.now
    end

    MAPPING = {
      "MemTotal" => :mem_total,
      "MemFree" => :mem_free,
      "Buffers" => :buffers,
      "Cached" => :cached,
      "SwapCached" => :swap_cached,
      "Active" => :active,
      "Inactive" => :inactive,
      "Active(anon)" => :active_anon,
      "Inactive(anon)" => :inactive_anon,
      "Active(file)" => :active_file,
      "Inactive(file)" => :inactive_file,
      "Unevictable" => :unevictable,
      "Mlocked" => :mlocked,
      "SwapTotal" => :swap_total,
      "SwapFree" => :swap_free,
      "Dirty" => :dirty,
      "Writeback" => :writeback,
      "AnonPages" => :anon_pages,
      "Mapped" => :mapped,
      "Shmem" => :shmem,
      "Slab" => :slab,
      "SReclaimable" => :s_reclaimable,
      "SUnreclaim" => :s_unreclaim,
      "KernelStack" => :kernel_stack,
      "PageTables" => :page_tables,
      "NFS_Unstable" => :nfs_unstable,
      "Bounce" => :bounce,
      "WritebackTmp" => :writeback_tmp,
      "CommitLimit" => :commit_limit,
      "Committed_AS" => :committed_as,
      "VmallocTotal" => :vmalloc_total,
      "VmallocUsed" => :vmalloc_used,
      "VmallocChunk" => :vmalloc_chunk,
      "HardwareCorrupted" => :hardware_corrupted,
      "AnonHugePages" => :anon_huge_pages,
      "HugePages_Total" => :huge_pages_total,
      "HugePages_Free" => :huge_pages_free,
      "HugePages_Rsvd" => :huge_pages_rsvd,
      "HugePages_Surp" => :huge_pages_surp,
      "Hugepagesize" => :hugepagesize,
      "DirectMap4k" => :direct_map4k,
      "DirectMap2M" => :direct_map2m,
    }

    set_known_metrics MAPPING.values

    MAPPING.each do |from, to|
      define_method(to) do
        cast_int(parsed[from])
      end
    end

    def extract(data = nil)
      MAPPING.values.inject({}) do |hash, method|
        hash[method] = send(method)
        hash
      end
    end

    def parsed
      @parsed ||= Hash[@data.scan(/^(.*?):\s*(\d+)/).map { |k, v| [k, cast_int(v)] }]
    end

  end
end

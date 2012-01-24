# -*- encoding : utf-8 -*-

class DeferredGarbageCollection

  DEFERRED_GC_THRESHOLD = (ENV['DEFER_GC'] || 10.0).to_f

  @@last_gc_run = Time.now

  def self.start
    return if RUBY_PLATFORM == "java"
    GC.disable if DEFERRED_GC_THRESHOLD > 0
  end

  def self.reconsider
    return if RUBY_PLATFORM == "java"
    if DEFERRED_GC_THRESHOLD > 0 && Time.now - @@last_gc_run >= DEFERRED_GC_THRESHOLD
      GC.enable
      GC.start
      GC.disable
      @@last_gc_run = Time.now
    end
  end

end

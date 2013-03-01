require "thread"

module WoCClassifier
  class TPool
    def initialize(numthreads)
      @numthreads = numthreads
    end

    # Start the thread pool up
    def start
      @mthread = monitor
    end

    # Monitor thread that watches the threadpool
    def monitor
      return Thread.new do
        while true do
          Thread.list.each do |thr|
            joined = thr.join(1)
          end
        end
      end
    end

    # Start a new worker thread
    def worker
      # Wait until we have space for you
      sleep(0.1) until (Thread.list.size < @numthreads)

      Thread.new do
        yield
      end
    end

    # Wait for the last worker threads to finish
    def teardown
      Thread.list.each do |thr|
        thr.join if (thr.alive? and thr != @mthread and thr != Thread.current)
      end
    end
  end
end

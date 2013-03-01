require "WoC_classifier/version"

module WoCClassifier
  class Extractor
    def initialize(listfile, prefix="", numthreads=8)
      @listfile = listfile
      @prefix = prefix
      @numthreads = numthreads
    end

    def extract
      raise "SYSTEM ERROR: Method missing"
    end
  end

  class Churn < Extractor
    def initialize(listfile, prefix="", numthreads=8)
      super(listfile, prefix, numthreads)
    end
  end
end

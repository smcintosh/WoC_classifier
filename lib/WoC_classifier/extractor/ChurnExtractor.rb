require "WoC_classifier/WoC/FileCategories.rb"

module WoCClassifier
  class ChurnExtractor < AbstractExtractor
    def initialize(listfile, prefix="", numthreads=8, summary=true)
      super(listfile, prefix, numthreads)
      @summary = summary
    end

    def header
      puts "@relation churn_data"
      puts
      puts "@attribute projname string"
      puts "@attribute tech string"
      puts "@attribute cmts numeric"
      puts "@attribute periods numeric"
      puts "@attribute authors numeric"
      puts "@attribute files numeric"
      puts "@attribute activity_med numeric"
      puts "@attribute lines_add_med numeric"
      puts "@attribute lines_del_med numeric"
      puts "@attribute lines_added numeric"
      puts "@attribute lines_deleted numeric"
      puts
      puts "@data"
    end

    def extract(prefix, filename)
      fname = "#{prefix}#{filename}"
      filecategories = FileCategories.new(filename, @langmap)
      filecategories.parseFile(fname)
      @print_mutex.synchronize do
        if (@summary)
          filecategories.printChurnDataSummary()
        else
          filecategories.printChurnData()
        end
      end
    end
  end
end

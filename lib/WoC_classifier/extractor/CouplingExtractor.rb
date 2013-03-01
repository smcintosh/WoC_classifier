require "WoC_classifier/WoC/FileCategories.rb"

module WoCClassifier
  class CouplingExtractor < AbstractExtractor
    def initialize(listfile, prefix="", numthreads=8, summary=true)
      super(listfile, prefix, numthreads)
      @summary = summary
    end

    def header
      puts "@relation rq1_data"
      puts
      puts "@attribute projname string"
      puts "@attribute tech string"
      puts "@attribute cmts numeric"
      puts "@attribute co_src_cmts numeric"
      puts "@attribute authors numeric"
      puts "@attribute co_src_authors numeric"
      puts "@attribute lines_add_med numeric"
      puts "@attribute lines_del_med numeric"
      puts "@attribute lines_add_comp numeric"
      puts "@attribute lines_del_comp numeric"
      puts "@attribute lines_add_churn numeric"
      puts "@attribute lines_del_churn numeric"
      puts "@attribute lines_add_comp_churn numeric"
      puts "@attribute lines_del_comp_churn numeric"
      puts
      puts "@data"
    end

    def extract(prefix, filename)
      fname = "#{prefix}#{filename}"
      filecategories = FileCategories.new(filename, @langmap)
      filecategories.parseFile(fname)
      @print_mutex.synchronize do
        filecategories.printCouplingData(@summary)
      end
    end
  end
end

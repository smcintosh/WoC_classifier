require "WoC_classifier/WoC/FileCategories.rb"

module WoCClassifier
  class OverviewExtractor < AbstractExtractor
    def initialize(listfile, prefix="", numthreads=8)
      super(listfile, prefix, numthreads)
    end

    def header
      puts "@relation prelim_data"
      puts
      puts "@attribute projname string"

      @langmap.sort.each do |lang, type|
        if (type == "programming" or type == "buildtech")
          puts "@attribute #{lang.gsub(" ", "").gsub("+","X")} numeric"
        end
      end
      puts "@attribute total numeric"
      puts "@attribute unclass numeric"
      puts "@attribute numcommits numeric"
      puts "@attribute numauthors numeric"
      puts
      puts "@data"
    end

    def print(filecategories)
      @print_mutex.synchronize do
        filecategories.printBuildData
      end
    end
  end
end

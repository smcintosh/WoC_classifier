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
      if (@summary)
        puts "@attribute cmts numeric"
        puts "@attribute periods numeric"
        puts "@attribute authors numeric"
        puts "@attribute files numeric"
        puts "@attribute activity_med numeric"
      else
        puts "@attribute period numeric"
        puts "@attribute mycmts numeric"
        puts "@attribute allcmts numeric"
        puts "@attribute myfiles numeric"
        puts "@attribute allfiles numeric"
        puts "@attribute myauthors numeric"
        puts "@attribute allauthors numeric"
      end

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
        filecategories.printChurnData(@summary)
      end
    end
  end
end

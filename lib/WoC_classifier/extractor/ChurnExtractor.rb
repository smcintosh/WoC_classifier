require "WoC_classifier/WoC/FileCategories.rb"

module WoCClassifier
  class AbstractChurnExtractor < AbstractExtractor
    def header
      puts "@relation churn_data"
      puts
      puts "@attribute projname string"
      puts "@attribute tech string"

      header_body

      puts "@attribute lines_add_med numeric"
      puts "@attribute lines_del_med numeric"
      puts "@attribute lines_added numeric"
      puts "@attribute lines_deleted numeric"
      puts
      puts "@data"
    end

    def header_body
      raise MISSING
    end
  end

  class MonthlyChurnExtractor < AbstractChurnExtractor
    def header_body
      puts "@attribute period numeric"
      puts "@attribute mycmts numeric"
      puts "@attribute allcmts numeric"
      puts "@attribute myfiles numeric"
      puts "@attribute allfiles numeric"
      puts "@attribute myauthors numeric"
      puts "@attribute allauthors numeric"
    end

    def print(filecategories)
      @print_mutex.synchronize do
        filecategories.printChurnDataMonthly
      end
    end
  end

  class MedianChurnExtractor < AbstractChurnExtractor
    def header_body
      puts "@attribute cmts numeric"
      puts "@attribute periods numeric"
      puts "@attribute authors numeric"
      puts "@attribute files numeric"
      puts "@attribute activity_med numeric"
    end

    def print(filecategories)
      @print_mutex.synchronize do
        filecategories.printChurnDataMedian
      end
    end
  end
end

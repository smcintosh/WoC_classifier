require "WoC_classifier/WoC/FileCategories.rb"

module WoCClassifier
  class AbstractCouplingExtractor < AbstractExtractor
    def header
      puts "@relation source_build_coupling_data"
      puts
      puts "@attribute projname string"
      puts "@attribute tech string"

      header_body

      puts
      puts "@data"
    end

    def header_body
      raise MISSING
    end
  end

  class MonthlyCouplingExtractor < AbstractCouplingExtractor
    def header_body
      puts "@attribute lang string"
      puts "@attribute period numeric"
      puts "@attribute bldcmts numeric"
      puts "@attribute srccmts numeric"
      puts "@attribute cocmts numeric"
      puts "@attribute bldauthors numeric"
      puts "@attribute srcauthors numeric"
      puts "@attribute coauthors numeric"
    end

    def print(filecategories)
      @print_mutex.synchronize do
        filecategories.printCouplingDataMonthly
      end
    end
  end

  class MedianCouplingExtractor < AbstractCouplingExtractor
    def header_body
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
    end

    def print(filecategories)
      @print_mutex.synchronize do
        filecategories.printCouplingDataMedian
      end
    end
  end
end

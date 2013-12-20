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

    def output(proj, filecategories)
      allcommits = filecategories.allcommits
      @print_mutex.synchronize do
        filecategories.each_nonempty_buildtech do |catname, category|
          category.printPeriods(proj, catname, allcommits.periods, allcommits.commits)
        end
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

    def output(proj, filecategories)
      allcommits = filecategories.allcommits
      numauthors = filecategories.allauthors.size
      numfiles = filecategories.allfiles.size
      @print_mutex.synchronize do
        filecategories.each_nonempty_buildtech do |catname, category|
          category.print(proj, catname, allcommits.periods, allcommits.commits)
        end

        puts "#{proj},project,#{allcommits.size},#{allcommits.periods.size},#{numauthors},#{numfiles},1,0,0,0,0"
      end
    end
  end
end

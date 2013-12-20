require "WoC_classifier/WoC/FileCategories.rb"

module WoCClassifier
  class AdoptionExtractor < AbstractExtractor
    def header
      puts "@relation adoption_data"
      puts
      puts "@attribute projname string"
      puts "@attribute tech string"
      puts "@attribute adoption_date numeric"
      puts "@attribute adoption_delay numeric"
      puts
      puts "@data"
    end

    def output(proj, filecategories)
      allcommits = filecategories.allcommits
      @print_mutex.synchronize do
        puts "#{proj},project,#{allcommits.firstCommitPeriod},0"
        filecategories.each_nonempty_buildtech do |catname, category|
          puts "#{proj},#{catname},#{category.firstCommitPeriod},#{category.firstCommitDelay(allcommits.firstCommitPeriod, allcommits.lastCommitPeriod)}"
        end
      end
    end
  end
end

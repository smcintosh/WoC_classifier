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

    def firstCommitDelay(category, realfirst, reallast)
      catfirst = category.periods.sort.first
      return (catfirst-realfirst)/(reallast-realfirst)
    end

    def output(proj, filecategories)
      periods = filecategories.allcommits.periods.sort
      @print_mutex.synchronize do
        puts "#{proj},project,#{periods.first},0"
        filecategories.each_nonempty_buildtech do |catname, category|
          catperiods = category.periods.sort
          puts "#{proj},#{catname},#{catperiods.first},#{firstCommitDelay(category, periods.first, periods.last)}"
        end
      end
    end
  end
end

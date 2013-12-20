require "WoC_classifier/WoC/FileCategories.rb"

module WoCClassifier
  class AdoptionExtractor < AbstractExtractor
    def initialize(listfile, prefix="", numthreads=8)
      super(listfile, prefix, numthreads)
    end

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

    def print(filecategories)
      @print_mutex.synchronize do
        filecategories.printTechAdoption
      end
    end
  end
end

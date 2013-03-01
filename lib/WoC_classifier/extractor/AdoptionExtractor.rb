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

    def extract(prefix, filename)
      fname = "#{prefix}#{filename}"
      filecategories = FileCategories.new(filename, @langmap)
      filecategories.parseFile(fname)
      @print_mutex.synchronize do
        filecategories.printTechAdoption
      end
    end
  end
end

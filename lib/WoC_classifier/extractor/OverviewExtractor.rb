require "WoC_classifier/WoC/FileCategories.rb"

module WoCClassifier
  class OverviewExtractor < AbstractExtractor
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

    def output(proj, filecategories)
      numfiles = filecategories.allfiles.size
      numcommits = filecategories.allcommits.commits.size
      numauthors = filecategories.allauthors.size
      numunclass = filecategories.unclass.files.size

      @print_mutex.synchronize do
        print "#{proj}"
        filecategories.each_lang_and_tech do |cat|
          print ",#{cat.files.size}"
        end

        puts ",#{numfiles},#{numunclass.to_f/numfiles.to_f},#{numcommits},#{numauthors}"
      end
    end
  end
end

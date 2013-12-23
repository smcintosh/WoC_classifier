require "WoC_classifier/WoC/FileCategories.rb"

module WoCClassifier
  class SizeExtractor < AbstractExtractor
    def header
      puts "@relation size_data"
      puts
      puts "@attribute projname string"
      puts "@attribute lang string"
      puts "@attribute size numeric"
      puts "@attribute type {PROG,BUILD}"
      puts
      puts "@data"
    end

    def output(proj, filecategories)
      @print_mutex.synchronize do
        filecategories.each_nonempty_proglang do |lang, category|
          puts "#{proj},#{lang},#{category.files.size},PROG"
        end

        filecategories.each_nonempty_buildtech do |tech, category|
          puts "#{proj},#{tech},#{category.files.size},BUILD"
        end
      end
    end
  end
end

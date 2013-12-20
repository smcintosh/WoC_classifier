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

    def output(proj, filecategories)
      allcommits = filecategories.allcommits
      categories = filecategories.categories
      @print_mutex.synchronize do
        filecategories.each_nonempty_buildtech do |tech, bldcategory|
          filecategories.each_nonempty_proglang do |lang, srccategory|
            bldcategory.printPeriodicCouplingWith([srccategory], allcommits.periods, proj, lang, tech)
          end

          bldcategory.printPeriodicCouplingWith(categories.values,allcommits.periods, proj, "all", tech)
        end
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

    def output(proj, filecategories)
      allcommits = filecategories.allcommits
      allauthors = filecategories.allauthors

      @print_mutex.synchronize do
        filecategories.each_nonempty_buildtech do |tech, bldcategory|
          bldcommits = bldcategory.commits.keys.to_set
          srcbldcommits = Set.new
          bldauthors = bldcategory.authors
          srcbldauthors = Set.new

          filecategories.each_nonempty_proglang do |lang, srccategory|
            srccommits = srccategory.mycommitsinperiods(bldcategory.myperiods(allcommits.periods))
            mysrcbldcommits = srccommits.intersection(bldcommits)
            srcbldcommits = srcbldcommits.union(mysrcbldcommits)

            srcauthors = srccategory.authorsincommits(srccategory.commits, srccommits)
            mysrcbldauthors = srcauthors.intersection(bldauthors)
            srcbldauthors = srcbldauthors.union(mysrcbldauthors)

            printLine(proj, "#{lang}-#{tech}", srccommits, mysrcbldcommits, srcauthors, mysrcbldauthors, srccategory)
          end

          printLine(proj, tech, bldcommits, srcbldcommits, bldauthors, srcbldauthors, bldcategory)
        end

        printLine(proj, "project", allcommits.commits, Set.new, allauthors, Set.new, CategoryStats.new)
      end
    end

    def printLine(proj, tech, cmts, coupledcmts, authors, coupledauthors, category)
      puts "#{proj},#{tech},#{cmts.size},#{coupledcmts.size},#{authors.size},#{coupledauthors.size},#{category.linesmedian(cmts, true)},#{category.linesmedian(cmts, false)},#{category.linesmedian(cmts, true, false)},#{category.linesmedian(cmts, false, false)},#{category.churn(cmts, true)},#{category.churn(cmts, false)},#{category.churn(cmts, true, false)},#{category.churn(cmts, false, false)}"
    end

  end
end

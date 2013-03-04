# External
require "set"

# Internal
require "WoC_classifier/WoC/CategoryStats.rb"

class FileCategories
  def initialize(proj, langmap)
    @allfiles = Set.new
    @allcommits = CategoryStats.new
    @allauthors = Set.new
    @unclass = CategoryStats.new
    @projname = proj
    @langmap = langmap

    @categories = {}
    @langmap.each do |lang, type|
      @categories[lang] = CategoryStats.new()
    end

    @build_categories = ["Makefile", "Rake", "Jam", "SCons", "Autotools",
      "CMake", "Ant", "Maven", "Ivy", "Bundler"]
  end

  def clean_file_path(dirty)
    dirtysplit = dirty.split(" => ")
    clean = ""

    dirtysplit.size.times do |i|
      clean.gsub!(/\{.*$/, '')
        clean << dirtysplit[i].sub(/\}/, '')
    end

    return (clean)
  end

  def parseFile(fname)
    File.read(fname).each_line do |line|
      line.strip!

      # Parse the line
      projpath,commitid,author,commiter,aeml,ceml,lines,authtime,committime,commitfile,message = line.split(";")

      commitfile = clean_file_path(commitfile)

      @allfiles.add(commitfile)
      @allcommits.add(commitid, commitfile, author, lines, authtime)
      @allauthors.add(author)

      lang = getlang(commitfile)
      if (lang and @categories[lang])
        @categories[lang].add(commitid, commitfile, author, lines, authtime)
      else
        @unclass.add(commitid, commitfile, author, lines, authtime)
      end
    end
  end

  def printBuildData
    print "#{@projname}"
    @categories.sort.each do |lang, cat|
      if (@langmap[lang] == "programming" or @langmap[lang] == "buildtech")
        print ",#{cat.filecount}"
      end
    end

    puts ",#{@allfiles.size},#{@unclass.filecount.to_f/@allfiles.size.to_f},#{@allcommits.size},#{@allauthors.size}"
    STDOUT.flush
  end

  def getlang(fname)
    tortn = nil
    langs = Linguist::Language.find_by_filename(fname.split("/").last)
    langs.each do |lang|
      if (lang.type.to_s == "buildtech")
        tortn = lang.name
        break
      end
    end

    if (!tortn and langs.first)
      tortn = langs.first.name
    end

    return tortn
  end

  def printChurnData(summary=true)
    @build_categories.each do |catname|
      if (@categories[catname].size > 0)
        if (summary)
          print "#{@projname},#{catname},"
          @categories[catname].print(@allcommits.periods, @allcommits.commits)
          puts
        else
          @categories[catname].printPeriods(@projname, catname, @allcommits.periods, @allcommits.commits)
        end
      end
    end

    if (summary)
      puts "#{@projname},project,#{@allcommits.size},#{@allcommits.periods.size},#{@allauthors.size},#{@allfiles.size},1,0,0,0,0"
    end
  end

  def printCouplingData(summary = true)
    @build_categories.each do |catname|
      if (@categories[catname].size > 0)
        if (summary)
          bldcommits = @categories[catname].commits.keys.to_set
          bldauthors = @categories[catname].authors
          srcbldcommits = Set.new
          srcbldauthors = Set.new

          @categories.each do |lang,category|
            next if (@langmap[lang] != "programming" or category.size <= 0)

            srccommits = category.commits.keys.to_set
            srcauthors = category.authors
            mysrcbldcommits = srccommits.intersection(bldcommits)
            mysrcbldauthors = srcauthors.intersection(bldauthors)
            srcbldcommits = srcbldcommits.union(mysrcbldcommits)
            srcbldauthors = srcbldauthors.union(mysrcbldauthors)

            puts "#{@projname},#{lang}-#{catname},#{srccommits.size},#{mysrcbldcommits.size},#{srcauthors.size},#{mysrcbldauthors.size},#{category.linesmedian(bldcommits, true)},#{category.linesmedian(bldcommits, false)},#{@categories[catname].linesmedian(srccommits, true, false)},#{@categories[catname].linesmedian(srccommits, false, false)},#{@categories[catname].churn(srccommits, true)},#{@categories[catname].churn(srccommits, false)},#{@categories[catname].churn(srccommits, true, false)},#{@categories[catname].churn(srccommits, false, false)}"
          end

          puts "#{@projname},#{catname},#{bldcommits.size},#{srcbldcommits.size},#{bldauthors.size},#{srcbldauthors.size},#{@categories[catname].linesmedian(srcbldcommits, true)},#{@categories[catname].linesmedian(srcbldcommits, false)},#{@categories[catname].linesmedian(srcbldcommits, true, false)},#{@categories[catname].linesmedian(srcbldcommits, false, false)},#{@categories[catname].churn(srcbldcommits, true)},#{@categories[catname].churn(srcbldcommits, false)},#{@categories[catname].churn(srcbldcommits, true, false)},#{@categories[catname].churn(srcbldcommits, false, false)}"
        else
          @categories.each do |lang,category|
            if (@langmap[lang] == "programming" and category.size > 0)
              @categories[catname].printPeriodicCouplingWith([category], @allcommits.periods, @projname, lang, catname)
            end
          end

          @categories[catname].printPeriodicCouplingWith(@categories.values,@allcommits.periods, @projname, "all", catname)
        end
      end
    end

    if (summary)
      puts "#{@projname},project,#{@allcommits.size},0,#{@allauthors.size},0,0,0,0,0,0,0,0,0"
    end
  end

  def printTechAdoption
    @build_categories.each do |catname|
      if (@categories[catname].size > 0)
        puts "#{@projname},#{catname},#{@categories[catname].firstCommitPeriod},#{@categories[catname].firstCommitDelay(@allcommits.firstCommitPeriod, @allcommits.lastCommitPeriod)}"
      end
    end
  end
end

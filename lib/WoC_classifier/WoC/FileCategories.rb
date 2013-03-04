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
      lsplit = line.split(";")

      commitfile = clean_file_path(lsplit[9])

      @allfiles.add(commitfile)
      @allcommits.add(lsplit[1], commitfile, lsplit[2], lsplit[6], lsplit[7])
      @allauthors.add(lsplit[2])

      lang = getlang(commitfile)
      if (lang and @categories[lang])
        @categories[lang].add(lsplit[1], commitfile, lsplit[2], lsplit[6], lsplit[7])
      else
        @unclass.add(lsplit[1], commitfile, lsplit[2], lsplit[6], lsplit[7])
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

  def printCouplingDataSummary()
    each_nonempty_buildtech do |catname|
      each_nonempty_proglang do |lang, category|
        @categories[catname].printPeriodicCouplingWith([category], @allcommits.periods, @projname, lang, catname)
      end

      @categories[catname].printPeriodicCouplingWith(@categories.values,@allcommits.periods, @projname, "all", catname)
    end
  end

  def each_nonempty_proglang
    @categories.each do |lang, category|
      if (@langmap[lang] == "programming" and category.size > 0)
        yield lang,category
      end
    end
  end

  def each_nonempty_buildtech
    @build_categories.each do |catname|
      if (@categories[catname].size > 0)
        yield catname
      end
    end
  end

  def printCouplingData()
    each_nonempty_buildtech do |catname|
      bldcommits = @categories[catname].commits.keys.to_set
      srcbldcommits = Set.new
      bldauthors = @categories[catname].authors
      srcbldauthors = Set.new

      each_nonempty_proglang do |lang,category|
        srccommits = category.commits.keys.to_set
        mysrcbldcommits = srccommits.intersection(bldcommits)
        srcbldcommits = srcbldcommits.union(mysrcbldcommits)

        srcauthors = category.authors
        mysrcbldauthors = srcauthors.intersection(bldauthors)
        srcbldauthors = srcbldauthors.union(mysrcbldauthors)

        puts "#{@projname},#{lang}-#{catname},#{srccommits.size},#{mysrcbldcommits.size},#{srcauthors.size},#{mysrcbldauthors.size},#{category.linesmedian(bldcommits, true)},#{category.linesmedian(bldcommits, false)},#{@categories[catname].linesmedian(srccommits, true, false)},#{@categories[catname].linesmedian(srccommits, false, false)},#{@categories[catname].churn(srccommits, true)},#{@categories[catname].churn(srccommits, false)},#{@categories[catname].churn(srccommits, true, false)},#{@categories[catname].churn(srccommits, false, false)}"
      end

      puts "#{@projname},#{catname},#{bldcommits.size},#{srcbldcommits.size},#{bldauthors.size},#{srcbldauthors.size},#{@categories[catname].linesmedian(srcbldcommits, true)},#{@categories[catname].linesmedian(srcbldcommits, false)},#{@categories[catname].linesmedian(srcbldcommits, true, false)},#{@categories[catname].linesmedian(srcbldcommits, false, false)},#{@categories[catname].churn(srcbldcommits, true)},#{@categories[catname].churn(srcbldcommits, false)},#{@categories[catname].churn(srcbldcommits, true, false)},#{@categories[catname].churn(srcbldcommits, false, false)}"
    end

    puts "#{@projname},project,#{@allcommits.size},0,#{@allauthors.size},0,0,0,0,0,0,0,0,0"
  end

  def printTechAdoption
    @build_categories.each do |catname|
      if (@categories[catname].size > 0)
        puts "#{@projname},#{catname},#{@categories[catname].firstCommitPeriod},#{@categories[catname].firstCommitDelay(@allcommits.firstCommitPeriod, @allcommits.lastCommitPeriod)}"
      end
    end
  end
end

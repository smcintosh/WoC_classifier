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

  def updateTotals(commitid, commitfile, author, lines, authtime)
    @allfiles.add(commitfile)
    @allcommits.add(commitid, commitfile, author, lines, authtime)
    @allauthors.add(author)
  end

  def updateCategories(commitid, commitfile, author, lines, authtime)
    lang = getlang(commitfile)
    if (lang and @categories[lang])
      @categories[lang].add(commitid, commitfile, author, lines, authtime)
    else
      @unclass.add(commitid, commitfile, author, lines, authtime)
    end
  end

  def parseFile(fname)
    File.read(fname).each_line do |line|
      line.strip!

      # Parse the line
      projpath,commitid,author,commiter,aeml,ceml,lines,authtime,committime,commitfile,message = line.split(";")

      commitfile = clean_file_path(commitfile)

      updateTotals(commitid, commitfile, author, lines, authtime)
      updateCategories(commitid, commitfile, author, lines, authtime)
    end
  end

  def each_lang_and_tech
    @categories.sort.each do |lang, cat|
      if (@langmap[lang] == "programming" or @langmap[lang] == "buildtech")
        yield cat
      end
    end
  end

  def printBuildData
    print "#{@projname}"
    each_lang_and_tech do |cat|
      print ",#{cat.filecount}"
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

  # USEFUL ITERATORS
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


  # CHURN
  def printChurnData(summary=true)
    if (summary)
      printChurnDataSummary()
    else
      printChurnDataMonthly()
    end
  end

  def printChurnDataSummary()
    each_nonempty_buildtech do |catname|
      print "#{@projname},#{catname},"
      @categories[catname].print(@allcommits.periods, @allcommits.commits)
      puts
    end

    puts "#{@projname},project,#{@allcommits.size},#{@allcommits.periods.size},#{@allauthors.size},#{@allfiles.size},1,0,0,0,0"
  end

  def printChurnDataMonthly()
    each_nonempty_buildtech do |catname|
      @categories[catname].printPeriods(@projname, catname, @allcommits.periods, @allcommits.commits)
    end
  end

  # COUPLING
  def printCouplingData(summary=true)
    if (summary)
      printCouplingDataSummary()
    else
      printCouplingDataMonthly()
    end
  end

  def printCouplingDataSummary()
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

        printCouplingDataSummaryLine("#{lang}-#{catname}", srccommits, mysrcbldcommits, srcauthors, mysrcbldauthors, category)
      end

      printCouplingDataSummaryLine(catname, bldcommits, srcbldcommits, bldauthors, srcbldauthors, @categories[catname])
    end

    printCouplingDataSummaryLine("project", @allcommits.commits, Set.new, @allauthors, Set.new, CategoryStats.new)
  end

  def printCouplingDataSummaryLine(techname, cmts, coupledcmts, authors, coupledauthors, category)
    puts "#{@projname},#{techname},#{cmts.size},#{coupledcmts.size},#{authors.size},#{coupledauthors.size},#{category.linesmedian(cmts, true)},#{category.linesmedian(cmts, false)},#{category.linesmedian(cmts, true, false)},#{category.linesmedian(cmts, false, false)},#{category.churn(cmts, true)},#{category.churn(cmts, false)},#{category.churn(cmts, true, false)},#{category.churn(cmts, false, false)}"
  end

  # ADOPTION
  def printTechAdoption
    @build_categories.each do |catname|
      if (@categories[catname].size > 0)
        puts "#{@projname},#{catname},#{@categories[catname].firstCommitPeriod},#{@categories[catname].firstCommitDelay(@allcommits.firstCommitPeriod, @allcommits.lastCommitPeriod)}"
      end
    end
  end

  def printCouplingDataMonthly()
    each_nonempty_buildtech do |catname|
      each_nonempty_proglang do |lang, category|
        @categories[catname].printPeriodicCouplingWith([category], @allcommits.periods, @projname, lang, catname)
      end

      @categories[catname].printPeriodicCouplingWith(@categories.values,@allcommits.periods, @projname, "all", catname)
    end
  end
end

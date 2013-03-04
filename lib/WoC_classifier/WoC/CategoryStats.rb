#External
require "set"

# Internal
require "WoC_classifier/WoC/Commit.rb"

class CategoryStats
  def initialize()
    @files = {}
    @commits = {}
    @authors = Set.new
    @lines_added = []
    @lines_deleted = []
  end

  def add(commitid, fname, author, lines, timestamp)
    @files[fname] = [] if (!@files[fname])
    @files[fname].push(commitid)

    @commits[commitid] = Commit.new(author, timestamp) if (!@commits[commitid])
    @commits[commitid].add(fname, lines)

    @authors.add(author)

    added,deleted= @commits[commitid].getEditedLinesForFile(fname)
    @lines_added.push(added.to_i)
    @lines_deleted.push(deleted.to_i)
  end

  def filecount
    return @files.size
  end

  def periods
    rtn = Set.new
    @commits.each do |cid, commit|
      rtn.add(commit.timeperiod)
    end

    return rtn
  end

  def myperiods(allperiods)
    rtn = Set.new
    myperiods = periods.sort

    allperiods.each do |period|
      rtn.add(period) if (period >= myperiods.first and period <= myperiods.last)   
    end

    return rtn
  end

  def commitsinperiod(commits, period)
    commitset = Set.new
    commits.each do |cid, commit|
      commitset.add(cid) if (commit.timeperiod == period)
    end

    return commitset
  end

  def size
    return @commits.size
  end

  def authorsincommits(commits, cids)
    authorset = Set.new

    cids.each do |cid|
      authorset.add(commits[cid].author)
    end

    return authorset
  end

  def filesincommits(commits, cids)
    fileset = Set.new

    cids.each do |cid|
      fileset.merge(commits[cid].files)
    end


    return fileset 
  end

  def getchurn(commits, add=true)
    return commits.inject(0) {|sum, n| sum + @commits[n].lines(add) }
  end

  def print(allperiods, allcommits)
    ratios = []
    addsizes = []
    delsizes = []

    pset = myperiods(allperiods)
    pset.each do |period|
      mycmts = commitsinperiod(@commits, period) 
      allcmts = commitsinperiod(allcommits, period)

      ratios << mycmts.size.to_f / allcmts.size.to_f

      addsizes << getchurn(mycmts, true)
      delsizes << getchurn(mycmts, false)
    end

    STDOUT.print "#{@commits.size},#{pset.size},#{@authors.size},#{@files.size},#{median(ratios)},#{median(@lines_added)},#{median(@lines_deleted)},#{median(addsizes)},#{median(delsizes)}"
  end


  def printPeriods(projname, tech, allperiods, allcommits)
    myperiods(allperiods).each do |period|
      mypcommits = commitsinperiod(@commits, period)
      allpcommits = commitsinperiod(allcommits, period)
      mypauthors = authorsincommits(@commits, mypcommits)
      allpauthors = authorsincommits(allcommits, allpcommits)
      mypfiles = filesincommits(@commits, mypcommits)
      allpfiles = filesincommits(allcommits, allpcommits)
      STDOUT.puts "#{projname},#{period},#{tech},#{mypcommits.size},#{allpcommits.size},#{mypfiles.size},#{allpfiles.size},#{mypauthors.size},#{allpauthors.size},#{linesmedian(mypcommits, true)},#{linesmedian(mypcommits, false)}"
    end
  end

  def printPeriodicCouplingWith(categories, allperiods, projname, lang, tech)
    myperiods(allperiods).each do |period|
      bldcids = commitsinperiod(@commits, period)

      srccids = Set.new
      categories.each do |category|
        srccids = srccids.union(commitsinperiod(category.commits, period))
      end

      srcbldcids = bldcids.intersection(srccids)

      puts "#{projname},#{period},#{tech},#{lang},#{bldcids.size},#{srccids.size},#{srcbldcids.size}"
    end
  end

  def median(arr)
    sorted = arr.sort

    if (arr.size > 2)
      mid = arr.size/2
      med = (arr.size % 2 == 0) ? (arr[mid-1] + arr[mid]) / 2 : arr[mid]
    elsif (arr.size > 0)
      med = arr[0]
    else
      med = 0
    end

    return med
  end

  def linesmedian(commitlist, add=true, inset=true)
    lines = []
    @commits.each do |cid, commit|
      if ((inset and commitlist.include?(cid)) or (!inset and !commitlist.include?(cid)))
        lines << commit.lines(add)
      end
    end

    return median(lines)
  end

  def churn(commitlist, add, inset=true)
    lines = []
    inter = commitlist.to_set.intersection(@commits.keys.to_set)

    thecommits = inset ? inter : @commits.keys.to_set - inter

    churn = 0
    thecommits.each do |cid|
      churn += @commits[cid].lines(add)
    end

    return churn
  end

  def firstCommitPeriod
    return periods.sort.first
  end

  def lastCommitPeriod
    return periods.sort.last
  end

  def firstCommitDelay(realfirst, reallast)
    return (firstCommitPeriod-realfirst)/(reallast-realfirst)
  end

  attr_reader :commits
  attr_reader :authors
end

# External
require "set"

# Internal
require "WoC_classifier/WoC/CategoryStats.rb"

module WoCClassifier
  class FileCategories
    attr_reader :allauthors
    attr_reader :allcommits
    attr_reader :allfiles
    attr_reader :categories
    attr_reader :unclass

    def initialize(langmap)
      @allfiles = Set.new
      @allcommits = CategoryStats.new
      @allauthors = Set.new
      @unclass = CategoryStats.new
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
        if (@langmap[lang] == "programming" and category.commits.size > 0)
          yield lang,category
        end
      end
    end

    def each_nonempty_buildtech
      @build_categories.each do |catname|
        if (@categories[catname].commits.size > 0)
          yield catname,@categories[catname]
        end
      end
    end
  end
end

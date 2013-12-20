module WoCClassifier
  class Commit
    attr_reader :author

    def initialize(author, timestamp)
      @author = author
      @timestamp = Time.at(timestamp.to_i)
      @commitList = {}
    end

    def add(fname, lines)
      @commitList[fname] = lines
    end

    def getEditedLinesForFile(fname)
      @commitList[fname].split(":")
    end

    def timeperiod
      return @timestamp.year+(@timestamp.month.to_f - 1)/12.to_f
    end

    def files
      return @commitList.keys
    end

    def each_file
      @commitList.each do |fname, lines|
        yield fname, lines
      end
    end

    def lines(addlines=true)
      rtn = 0
      each_file do |fname, lines|
        add,del = lines.split(":")
        rtn += (addlines) ? add.to_i : del.to_i
      end

      return rtn
    end
  end
end

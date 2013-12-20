module WoCClassifier
  class CorpusSplitter
    def self.get_projname_git(line)
      pathsplit = line.split(";")[0].split("/")
      return pathsplit[pathsplit.size-1]
    end

    def self.get_projname_svn(line)
      return line.split(";")[0].gsub(/\//, "_")
    end

    def self.get_projname_cvs(line)
      pathsplit = line.split(";")[2].split("/")
      return pathsplit[1]
    end

    def self.parse_server_file(fname, mydir = "WoC_projects")
      old_pname = ""
      outfile = nil
      
      Dir.mkdir(mydir) if (!File.directory?(mydir))

      File.foreach(fname) do |line|
        line.strip!

        # Clean up
        # rykerE
        line.gsub!(/\/home\/store5\/bckp\/pcl\/store\/sources/, '')
        line.gsub!(/\/home\/store5\/sources/, '')
        line.gsub!(/\/home\/store5\/sources.new/, '')
        line.gsub!(/\/home\/store6\/sources/, '')
        line.gsub!(/\/home\/store4\/sources/, '')

        # pae, l1, l4
        line.gsub!(/\/store\/sources/, '')
        line.gsub!(/\/store1\/sources/, '')

        # l1, l2
        line.gsub!(/\/store/, '')
        line.gsub!(/\/store1/, '')

        line.gsub!(/\/\.git;/, ';')

        pname = get_projname_svn(line)

        if (pname != old_pname)
          puts "\t#{pname}"
          old_pname = pname
          outfile.close if (outfile)

          outfile = File.open("#{mydir}/#{pname}", "a")
        end

        outfile.puts(line)
      end
    end
  end
end

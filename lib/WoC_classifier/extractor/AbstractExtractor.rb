# External
require "linguist"

# Internal
require "WoC_classifier/util/TPool.rb"

module WoCClassifier
  class AbstractExtractor
    MISSING = "SYSTEM ERROR: Method missing"

    def initialize(listfile, prefix="", numthreads=8)
      @listfile = listfile
      @tpool = TPool.new(numthreads)

      # If a prefix has been provided, ensure it ends with a trailing '/'
      @prefix = prefix
      @prefix << "/" if (@prefix and !@prefix.empty? and @prefix[-1, 1] != '/')

      # Build the map of languages to language types
      @langmap = {}
      # TODO: This hack is in place until I can figure out a better way to get
      # this listing from github-linguist.
      YAML.load_file(File.expand_path("../languages.yml", __FILE__)).each do |name, options|
        @langmap[name] = options['type'] 
      end

      # Mutex for printing
      @print_mutex = Mutex.new
    end

    # Method that defines the main extraction workflow
    def extract_all
      header
      @tpool.start
      File.foreach(@listfile) do |file|
        file.strip!
        @tpool.worker do
          extract(@prefix, file)
        end
      end

      @tpool.teardown
    end

    # Abstract method that is defined by concrete extractors
    def header
      raise MISSING
    end

    # Abstract method that is defined by concrete extractors
    def extract(prefix, filename)
      raise MISSING
    end
  end
end

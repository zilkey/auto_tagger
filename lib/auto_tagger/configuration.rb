module AutoTagger

  class Configuration
    def initialize(options)
      @options = options
    end

    def stage
      @options[:stage]
    end

    def working_directory
      File.expand_path(@options[:path] || Dir.pwd)
    end

    def date_format
      @options[:date_format] ||= "%Y%m%d%H%M%S"
    end

    def push_refs?
      @options.fetch(:push_refs, true)
    end

    def fetch_refs?
      @options.fetch(:fetch_refs, true)
    end

    def remote
      @options.fetch(:remote, "origin")
    end

    def ref_path
      @options.fetch(:ref_path, "refs/tags")
    end

  end
  
end
module AutoTagger

  class Configuration
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def task
      if @options[:show_help]
        :help
      elsif @options[:show_version]
        :version
      else
        :tagger
      end
    end

    def stage
      @options[:stage]
    end

    def working_directory
      File.expand_path(path || Dir.pwd)
    end

    def help_text
      @options[:help_text]
    end

    def ref_prefix
      @options[:ref_prefix] ||= "/"
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

    private

    def path
      @options[:path]
    end

  end
  
end
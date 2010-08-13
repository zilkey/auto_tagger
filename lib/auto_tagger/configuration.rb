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

    def tag_separator
      @options[:tag_separator] ||= "/"
    end

    def date_format
      @options[:date_format] ||= "%Y%m%d%H%M%S"
    end

    def push_tags?
      @options.fetch(:push_tags, true)
    end

    def fetch_tags?
      @options.fetch(:fetch_tags, true)
    end

    private

    def path
      @options[:path]
    end

  end
  
end
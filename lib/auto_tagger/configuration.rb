module AutoTagger

  class Configuration
    def initialize(options)
      @options = options
    end

    def merged_options
      @merged_options ||= merged_options_with_auto_tagger_config_file
    end

    def merged_options_with_auto_tagger_config_file
      # read file and parse
      # merge in options
    end
    
    def stage
      merged_options[:stage]
    end

    def working_directory
      File.expand_path(merged_options[:path] || Dir.pwd)
    end

    def date_format
      merged_options[:date_format] ||= "%Y%m%d%H%M%S"
    end

    def push_refs?
      merged_options.fetch(:push_refs, true)
    end

    def fetch_refs?
      merged_options.fetch(:fetch_refs, true)
    end

    def remote
      merged_options.fetch(:remote, "origin")
    end

    def ref_path
      merged_options.fetch(:ref_path, "refs/tags")
    end

  end
  
end
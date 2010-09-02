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
      @options
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

    def stages
      merged_options[:stages].to_s.split(",").map{|stage| stage.strip}.reject{|stage| stage.to_s == ""}
    end

    def dry_run?
      merged_options.fetch(:dry_run, false)
    end

    def verbose?
      merged_options.fetch(:verbose, false)
    end

    def push_refs?
      merged_options.fetch(:push_refs, true)
    end

    def refs_to_keep
      merged_options.fetch(:refs_to_keep, 1).to_i
    end

    def fetch_refs?
      merged_options.fetch(:fetch_refs, true)
    end

    def remote
      merged_options.fetch(:remote, "origin")
    end

    def ref_path
      path = merged_options.fetch(:ref_path, "auto_tags")
      raise "#{path} is a reserved word in git.  Please use something else." if ["heads", "remotes"].include?(path)
      path
    end

  end
  
end
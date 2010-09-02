module AutoTagger

  class Configuration
    def initialize(options)
      @options = options
    end

    # you can't override this in the options file
    def opts_file
      @options[:opts_file]
    end

    # you can't override this in the options file
    def working_directory
      File.expand_path(@options[:path] || Dir.pwd)
    end

    def merged_options_with_auto_tagger_config_file
      file_options.merge(@options)
    end

    def file_options
      opts_file_path = opts_file ? File.expand_path(opts_file) : File.join(Dir.pwd, ".auto_tagger")
      file_options = {}
      if File.exists?(opts_file_path)
        text = File.read(opts_file_path)
        args = text.split("\n").map{|line| line.strip}.reject{|line| line == ""}
        file_options = AutoTagger::Options.from_file(args)
      end
      file_options
    end

    def specified_options
      file_options.merge(@options)
    end

    def merged_options
      @merged_options ||= merged_options_with_auto_tagger_config_file
    end

    def stage
      merged_options[:stage]
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

    def offline?
      merged_options.fetch(:offline, false)
    end

    def push_refs?
      !offline? && merged_options.fetch(:push_refs, true)
    end

    def executable
      merged_options.fetch(:executable, "git")
    end

    def refs_to_keep
      merged_options.fetch(:refs_to_keep, 1).to_i
    end

    def fetch_refs?
      !offline? && merged_options.fetch(:fetch_refs, true)
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
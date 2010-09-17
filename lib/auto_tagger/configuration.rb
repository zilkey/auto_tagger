module AutoTagger

  class Configuration

    class InvalidRefPath < StandardError
    end

    def initialize(options = {})
      @options = options
    end

    def working_directory
      File.expand_path(@options[:path] || Dir.pwd)
    end

    def opts_file
      file = @options[:opts_file] || ".auto_tagger"
      File.expand_path File.join(working_directory, file)
    end

    def file_settings
      return {} unless File.exists?(opts_file)
      args = File.read(opts_file).to_s.split("\n").map { |line| line.strip }
      args.reject! { |line| line == "" }
      AutoTagger::Options.from_file(args)
    end

    def settings
      file_settings.merge(@options)
    end

    def stages
      stages = settings[:stages] || []
      stages = stages.to_s.split(",").map { |stage| stage.strip } if stages.is_a?(String)
      stages.reject { |stage| stage.to_s == "" }.map {|stage| stage.to_s }
    end

    def stage
      stage = settings[:stage] || stages.last
      stage.nil? ? nil : stage.to_s
    end

    def date_separator
      settings[:date_separator] ||= ""
    end

    def dry_run?
      settings.fetch(:dry_run, false)
    end

    def verbose?
      settings.fetch(:verbose, false)
    end

    def offline?
      settings.fetch(:offline, false)
    end

    def fetch_refs?
      !offline? && settings.fetch(:fetch_refs, true)
    end

    def push_refs?
      !offline? && settings.fetch(:push_refs, true)
    end

    def executable
      settings[:executable] || "git"
    end

    def refs_to_keep
      (settings[:refs_to_keep] || 1).to_i
    end

    def remote
      settings[:remote] || "origin"
    end

    def ref_path
      path = settings[:ref_path] || "tags"
      if ["heads", "remotes"].include?(path)
        raise InvalidRefPath, "#{path} is a reserved word in git.  Please use something else."
      end
      path
    end

  end

end
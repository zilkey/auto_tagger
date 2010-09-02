module AutoTagger
  class CommandLine

    def initialize(args)
      @args = args
    end

    def execute
      message = case task
        when :version
          "AutoTagger version #{AutoTagger.version}"
        when :help
          options[:help_text]
        when :cleanup
          purged = AutoTagger::Base.new(options).cleanup
          "Deleted: #{purged}"
        when :list
          AutoTagger::Base.new(options).list.join("\n")
        else
          AutoTagger::Deprecator.warn("Please use create instead")
          ref = AutoTagger::Base.new(options).create_ref
          "Created ref #{ref.name}"
      end
      [true, message]
    end

    private

    def options
      @options ||= AutoTagger::Options.parse(@args)
    end

    def task
      if options[:show_help]
        :help
      elsif options[:show_version]
        :version
      elsif options[:cleanup]
        :cleanup
      elsif options[:list]
        :list
      else # options[:create]
        :tagger
      end
    end

  end
end
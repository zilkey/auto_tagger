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
        else
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
      else
        :tagger
      end
    end

  end
end
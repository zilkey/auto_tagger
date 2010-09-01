module AutoTagger
  class CommandLine

    def initialize(args)
      @args = args
    end

    def execute
      auto_tagger = AutoTagger::Base.new(options)

      case task
        when :version
          puts "AutoTagger version #{AutoTagger.version}"
          Kernel.exit(0)
        when :help
          puts options[:help_text]
          Kernel.exit(0)
        else
          auto_tagger.create_ref
          true
      end
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
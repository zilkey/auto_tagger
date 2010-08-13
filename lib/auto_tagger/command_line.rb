module AutoTagger

  class CommandLine
    def self.execute(args)
      options = AutoTagger::Options.parse(args)
      configuration = AutoTagger::Configuration.new(options)

      case configuration.task
        when :version
          puts "AutoTagger version #{AutoTagger.version}"
          Kernel.exit(0)
        when :help
          puts configuration.help_text
          Kernel.exit(0)
        else
          AutoTagger::Runner.new(configuration).create_tag
          true
      end
    end
  end

end
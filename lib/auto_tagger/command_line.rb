module AutoTagger
  class CommandLine

    def initialize(args)
      @args = args
    end

    def execute
      message = case options[:command]
        when :version
          "AutoTagger version #{AutoTagger.version}"
        when :help
          options[:help_text]
        when :cleanup
          purged = AutoTagger::Base.new(options).cleanup
          "Deleted: #{purged}"
        when :list
          AutoTagger::Base.new(options).list.join("\n")
        when :config
          AutoTagger::Configuration.new(options).specified_options.map do |key, value|
            "#{key} : #{value}"
          end.join("\n")
        else
          if options[:deprecated]
            AutoTagger::Deprecator.warn("Please use `autotag create #{options[:stage]}` instead")
          end
          ref = AutoTagger::Base.new(options).create_ref
          "Created ref #{ref.name}"
      end
      [true, message]
    end

    private

    def options
      @options ||= AutoTagger::Options.from_command_line(@args)
    end

  end
end
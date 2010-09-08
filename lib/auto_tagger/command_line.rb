module AutoTagger
  class CommandLine

    def initialize(args)
      @args = args
    end

    def execute
      case options[:command]
        when :version
          [true, "AutoTagger version #{AutoTagger.version}"]
        when :help
          [true, options[:help_text]]
        when :cleanup
          begin
            purged = AutoTagger::Base.new(options).cleanup
            [true, "Deleted: #{purged}"]
          rescue AutoTagger::Base::StageCannotBeBlankError
            [false, "You must provide a stage"]
          end
        when :delete_locally
          begin
            purged = AutoTagger::Base.new(options).delete_locally
            [true, "Deleted: #{purged}"]
          rescue AutoTagger::Base::StageCannotBeBlankError
            [false, "You must provide a stage"]
          end
        when :delete_on_remote
          begin
            purged = AutoTagger::Base.new(options).delete_on_remote
            [true, "Deleted: #{purged}"]
          rescue AutoTagger::Base::StageCannotBeBlankError
            [false, "You must provide a stage"]
          end
        when :list
          begin
            [true, AutoTagger::Base.new(options).list.join("\n")]
          rescue AutoTagger::Base::StageCannotBeBlankError
            [false, "You must provide a stage"]
          end
        when :config
          [true, AutoTagger::Configuration.new(options).settings.map { |key, value| "#{key} : #{value}" }.join("\n")]
        else
          begin
            create_message = []
            if options[:deprecated]
              create_message << AutoTagger::Deprecator.string("Please use `autotag create #{options[:stage]}` instead")
            end
            ref = AutoTagger::Base.new(options).create_ref
            create_message << "Created ref #{ref.name}"
            [true, create_message.join("\n")]
          rescue AutoTagger::Base::StageCannotBeBlankError
            [false, "You must provide a stage"]
          end
      end
    end

    private

    def options
      @options ||= AutoTagger::Options.from_command_line(@args)
    end

  end
end
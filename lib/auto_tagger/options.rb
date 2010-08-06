module AutoTagger

  class Options

    def initialize
      @options = {}
    end

    def [](key)
      @options[key]
    end

    def []=(key, value)
      @options[key] = value
    end

    def parse!(args)
      @args = args
      @expanded_args = @args.dup

      @args.extend(::OptionParser::Arguable)

      @args.options do |opts|
        opts.banner = ["", "  USAGE: autotag [options] STAGE [REPOSITORY]", "",
          "  Examples:",
          "",
          "    autotag demo",
          "    autotag demo .",
          "    autotag demo ../",
          "    autotag ci /data/myrepo",
          "    autotag --tag-separator - ci /data/myrepo", "", "",
        ].join("\n")

        opts.on("-s TAG_SEPARATOR", "--tag-separator TAG_SEPARATOR",
          "Sets the character used to separate the stage name",
          "from the timestamp in the tag.  Defaults to /") do |o|
          @options[:tag_separator] = o
        end

        opts.on_tail("-h", "--help", "-?", "You're looking at it.") do
          puts opts.help
          Kernel.exit(0)
        end

      end.parse!

      @options[:args] = @args.dup #whatever is left over
      self
    end

  end
end
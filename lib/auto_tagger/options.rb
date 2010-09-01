module AutoTagger

  class Options

    def self.parse(args)
      options = {}
      args.extend(::OptionParser::Arguable)

      args.options do |opts|
        opts.banner = [
          "",
          "  USAGE: autotag [options] STAGE [REPOSITORY]",
          "",
          "  Examples:",
          "",
          "    autotag help",
          "    autotag version",
          "    autotag demo",
          "    autotag demo .",
          "    autotag demo ../",
          "    autotag ci /data/myrepo",
          "    autotag --fetch-tags=false --push-tags=false ci /data/myrepo",
          "    autotag ci /data/myrepo --fetch-tags=false --push-tags=false",
          "",
          "",
        ].join("\n")

        opts.on("--date-format FORMAT",
                "Sets the format of the date for tags",
                "Defaults to %Y%m%d%H%M%S") do |o|
          options[:date_format] = o
        end

        opts.on("--fetch-tags FETCH_TAGS", TrueClass,
                "Whether or not to fetch tags before creating the tag",
                "Defaults to true") do |o|
          options[:fetch_refs] = o
        end

        opts.on("--push-tags PUSH_TAGS", TrueClass,
                "Whether or not to push tags after creating the tag",
                "Defaults to true") do |o|
          options[:push_refs] = o
        end

        opts.on("--offline", FalseClass,
                "Same as --fetch-tags=false and --push-tags=false") do |o|
          options[:push_refs] = false
          options[:fetch_refs] = false
        end

        opts.on("--remote",
                "specify the git remote") do |o|
          options[:remote] = o
        end

        opts.on("--ref-path",
                "specify the ref-path") do |o|
          options[:ref_path] = o
        end

        opts.on_tail("-h", "--help", "-?", "You're looking at it.") do
          options[:show_help] = true
        end

        opts.on_tail("--version", "Show version") do
          options[:show_version] = true
        end

      end.parse!

      options[:help_text] = args.options.help

      case args.first.to_s.downcase
        when * ["help", ""]
          options[:show_help] = true
        when "version"
          options[:show_version] = true
        else
          options[:stage] = args[0]
          options[:path] = args[1]
      end

      options
    end

  end
end
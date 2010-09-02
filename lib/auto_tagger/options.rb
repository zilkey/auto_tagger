module AutoTagger

  class Options

    def self.parse(args)
      options = {}
      args.extend(::OptionParser::Arguable)

      args.options do |opts|
        opts.banner = [
          "",
          "  USAGE: autotag command [stage] [options]",
          "",
          "  Examples:",
          "",
          "    autotag help",
          "    autotag version",
          "    autotag create demo",
          "    autotag create demo .",
          "    autotag create demo ../",
          "    autotag create ci /data/myrepo",
          "    autotag create ci /data/myrepo --fetch-tags=false --push-tags=false",
          "    autotag create ci /data/myrepo --offline",
          "    autotag create ci /data/myrepo --dry-run",
          "",
          "    autotag list demo",
          "",
          "    autotag cleanup demo --refs-to-keep=2",
          "    autotag cleanup demo --refs-to-keep=2 --dry-run",
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

        opts.on("--remote REMOTE",
                "specify the git remote",
                "Defaults to origin") do |o|
          options[:remote] = o
        end

        opts.on("--ref-path REF_PATH",
                "specify the ref-path",
                "Defaults to auto_tags") do |o|
          options[:ref_path] = o
        end

        opts.on("--stages STAGES",
                "specify a comma-separated list of stages") do |o|
          options[:stages] = o
        end

        opts.on("--offline", FalseClass,
                "Same as --fetch-tags=false and --push-tags=false") do |o|
          options[:push_refs] = false
          options[:fetch_refs] = false
        end

        opts.on("--dry-run",
                "doesn't execute anything, but logs what it would run") do |o|
          options[:dry_run] = true
        end

        opts.on("--verbose",
                "logs all commands") do |o|
          options[:verbose] = true
        end

        opts.on("--refs-to-keep REFS_TO_KEEP",
                "logs all commands") do |o|
          options[:refs_to_keep] = o
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
        when "cleanup"
          options[:cleanup] = true
          options[:stage] = args[1]
        when "list"
          options[:list] = true
          options[:stage] = args[1]
        when "create"
          options[:create] = true
          options[:stage] = args[1]
          options[:path] = args[2]
        else
          options[:create] = true
          options[:stage] = args[0]
          options[:path] = args[1]
      end

      options
    end

  end
end
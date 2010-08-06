module AutoTagger
  class Parser
    def self.parse!(args)
      new.parse!(args)
    end

    class << self
      alias_method :parse, :parse!
    end

    def parse!(args)
      options = {}
      parser(options).parse!(args)
      options
    end

    alias_method :parse, :parse!

    def parser(options)
      OptionParser.new do |parser|
        parser.banner = "USAGE: #{File.basename($0)} <stage> [<repository>]"

        parser.on('-s', '--tag-separator SEPARATOR', 'Set the tag separator') do |o|
          options[:tag_separator] = o
        end

        parser.on_tail('-h', '--help', "You're looking at it.") do
          puts parser
          exit
        end

        parser.on('-o', '--options PATH', 'Read configuration options from a file path.  (Defaults to .auto_tagger)') do |o|
          options[:options_file] = o || local_options_file
        end

        parser.on('-v', '--version', 'Show version') do
          puts AutoTagger::Version::STRING
          exit
        end
      end
    end
  end
end
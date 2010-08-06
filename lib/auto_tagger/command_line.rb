module AutoTagger

  class CommandLine
    def self.execute(args)
      new(args).execute!
    end

    def initialize(args)
      @args = args
      @configuration = nil
    end

    def execute!
      AutoTagger::Runner.new(configuration.stage, configuration.path).create_tag
      true
    end

    def configuration
      return @configuration if @configuration

      @configuration = AutoTagger::Configuration.new
      @configuration.parse!(@args)
      @configuration
    end
  end

end
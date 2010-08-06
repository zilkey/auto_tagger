module AutoTagger

  class Configuration
    attr_reader :options

    def initialize
      @options = Options.new
    end

    def parse!(args)
      @args = args
      @options.parse!(args)
      # @options[:some_thing] = some_value
    end

    def tag_separator
      @options[:tag_separator] ||= "/"
    end

    def stage
      @options[:args][0]
    end

    def path
      @options[:args][1]
    end

  end
  
end
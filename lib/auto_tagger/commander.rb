module AutoTagger
  class Commander

    attr_reader :path

    def initialize(path)
      @path = path
    end

    def execute(cmd)
      `#{command_in_context(path, cmd)}`
    end

    def execute?(cmd)
      system command_in_context(path, cmd)
    end

    private

    def command_in_context(cmd)
      "cd #{path} && #{cmd}"
    end
  end
end

module AutoTagger
  class Commander

    def initialize(path)
      @path = path
    end

    # Executes the command and returns the output as a string
    # TODO: redirect stderr to stdout so it shows up??
    def execute(cmd)
      `#{command_in_context(cmd)}`
    end

    # Executes the command and returns a boolean representing whether
    # the command passed or failed
    def execute?(cmd)
      system command_in_context(cmd)
    end

    private

    def command_in_context(cmd)
      "cd #{@path} && #{cmd}"
    end

  end
end

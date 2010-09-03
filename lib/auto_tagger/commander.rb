module AutoTagger
  class Commander

    def initialize(path, verbose)
      @path = path
      @verbose = verbose
    end

    def print(cmd)
      puts command_in_context(cmd)
    end

    def read(cmd)
      puts command_in_context(cmd) if @verbose
      `#{command_in_context(cmd)}`
    end

    def execute(cmd)
      puts command_in_context(cmd) if @verbose
      system command_in_context(cmd)
    end

    private
    
    def command_in_context(cmd)
      "cd #{@path} && #{cmd}"
    end

  end
end

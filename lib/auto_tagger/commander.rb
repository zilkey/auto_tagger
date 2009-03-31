class Commander
  class << self
    def execute(path, cmd)
      `#{command_in_context(path, cmd)}`
    end

    def execute!(path, cmd)
      system command_in_context(path, cmd)
    end
    
    def command_in_context(path, cmd)
      full_command = "cd #{path} && #{cmd}"
      puts full_command
      full_command
    end
  end
end


module AutoTagger
  class Commander
    class << self
      def execute(path, cmd)
        `#{command_in_context(path, cmd)}`
      end

      def execute!(path, cmd)
        system command_in_context(path, cmd)
      end

      def command_in_context(path, cmd)
        "cd #{path} && #{cmd}"
      end
    end
  end
end

module AutoTagger
  module Git

    #  A class that represents a git repo
    #
    #   repo.refs.create name, sha
    #   repo.refs.all
    #   repo.refs.push origin, pattern
    #   repo.refs.fetch origin, pattern
    #
    class Repo

      class NoPathProvidedError < StandardError
      end

      class NoSuchPathError < StandardError
      end

      class InvalidGitRepositoryError < StandardError
      end

      class GitCommandFailedError < StandardError
      end

      def initialize(given_path, options = {})
        @given_path = given_path
        @execute_commands = options.fetch(:execute_commands, true)
        @verbose = options[:verbose]
        @executable = options[:executable] || "git"
      end

      def path
        return @path if @path
        raise NoPathProvidedError if @given_path.to_s.strip == ""
        raise NoSuchPathError if !File.exists?(@given_path)
        raise InvalidGitRepositoryError if !File.exists?(File.join(@given_path, ".git"))
        @path = @given_path
      end

      def refs
        RefSet.new(self)
      end
      
      def ==(other)
        other.is_a?(AutoTagger::Git::Repo) && other.path == path
      end

      def latest_commit_sha
        read("rev-parse HEAD").strip
      end

      def read(cmd)
        commander.read(git_command(cmd))
      end

      def exec(cmd)
        if @execute_commands
          commander.execute(git_command(cmd)) || raise(GitCommandFailedError)
        else
          commander.print(git_command(cmd))
        end
      end

      private

      def git_command(cmd)
        "%s %s" % [@executable, cmd]
      end

      def commander
        AutoTagger::Commander.new(path, @verbose)
      end

    end
  end
end

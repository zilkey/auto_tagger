module AutoTagger
  module Git

    #  A class that represents a git repo
    #
    #   repo.refs.create name, sha
    #   repo.refs.all
    #   repo.refs.find_by_name name
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
        @execute_commands = options[:execute_commands]
        @verbose = options[:verbose]
      end

      def path
        return @path if @path
        raise NoPathProvidedError if @given_path.to_s.strip == ""
        raise NoSuchPathError if !File.exists?(@given_path)
        raise InvalidGitRepositoryError if !File.exists?(File.join(@given_path, ".git"))
        @path = @given_path
      end

      def ==(other)
        other.is_a?(AutoTagger::Git::Repo) && other.path == path
      end

      def latest_commit_sha
        read("rev-parse HEAD").strip
      end

      def read(cmd)
        commander.read("%s %s" % [git, cmd])
      end

      def exec(cmd)
        if @execute_commands
          commander.execute("%s %s" % [git, cmd]) || raise(GitCommandFailedError)
        else
          commander.print("%s %s" % [git, cmd])
        end
      end

      def refs
        RefSet.new(self)
      end

      def tags
        refs.all.select do |ref|
          ref.name =~ /^refs\/tags/
        end
      end

      def branches
        refs.all.select do |ref|
          ref.name =~ /^refs\/heads/
        end
      end

      def auto_tags
        refs.all.select do |ref|
          ref.name =~ /^refs\/auto_tags/
        end
      end

      private

      def commander
        AutoTagger::Commander.new(path, @verbose)
      end

      # TODO: make this an option one can pass in
      def git
        "/opt/local/bin/git"
      end

    end
  end
end
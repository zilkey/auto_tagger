module AutoTagger
  module Git
    class Repo

      class NoPathProvidedError < StandardError; end
      class NoSuchPathError < StandardError; end
      class InvalidGitRepositoryError < StandardError; end
      class GitCommandFailedError < StandardError; end

      attr_reader :path

      def initialize(path)
        @path = path
      end

      def ==(other)
        other.is_a?(AutoTagger::Git::Repo) && other.path == path
      end

      def exec(cmd)
        commander.execute(path, cmd)
      end

      def exec!(cmd)
        commander.execute?(path, cmd) || raise(GitCommandFailedError)
      end

      def refs
        @refset ||= RefSet.new(self)
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

      def validate
        if path.to_s.strip == ""
          raise NoPathProvidedError
        elsif ! File.exists?(path)
          raise NoSuchPathError
        elsif ! File.exists?(File.join(path, ".git"))
          raise InvalidGitRepositoryError
        else
          @path = path
        end
      end

      private

      def commander
        AutoTagger::Commander.new(path)
      end

      def git
        "/opt/local/bin/git"
      end

    end
  end
end

module AutoTagger
  module Git
    class RefSet
      attr_reader :repo

      def initialize(repo)
        @repo = repo
      end

      def all
        repo.exec("show-ref").split(/\n/).map do |line|
          parts = line.split(" ")
          Ref.new(parts.first, parts.last)
        end
      end

      def find_by_name(name)
        sha = repo.exec("rev-parse").strip
        Ref.new(name, sha)
      end

      def create(name, sha_or_ref)
        repo.exec "update-ref #{name} #{sha_or_ref}"
      end

      def push(pattern = "refs/autotags/*")
        repo.exec "push #{origin} #{pattern}:#{pattern}"
      end

      def fetch(pattern = "refs/autotags/*")
        repo.exec "fetch #{origin} #{pattern}:#{pattern}"
      end

      def origin
        "origin"
      end

    end
  end
end

module AutoTagger
  module Git
    class RefSet

      def initialize(repo)
        @repo = repo
      end

      def all
        @repo.read("show-ref").split(/\n/).map do |line|
          parts = line.split(" ")
          Ref.new(@repo, parts.first, parts.last)
        end
      end

      # name = refs/autotags/2009857463
      # returns a ref
      def find_by_name(name)
        sha = @repo.read("rev-parse").strip
        Ref.new(name, sha)
      end

      # name = refs/autotags/2009857463
      # returns a ref
      # should un-cache the refs in refset, or never memoize
      def create(name, sha_or_ref)
        ref = Ref.new(@repo, sha_or_ref, name)
        ref.save
      end

      # pattern = refs/autotags/*
      def push(pattern, remote = "origin")
        @repo.exec "push #{remote} #{pattern}:#{pattern}"
      end

      # pattern = refs/auto_tags/*
      def fetch(pattern, remote = "origin")
        @repo.exec "fetch #{remote} #{pattern}:#{pattern}"
      end

    end
  end
end

module AutoTagger
  module Git
    class RefSet

      def initialize(repo)
        @repo = repo
      end

      def all
        @repo.read("show-ref").split(/\n/).map do |line|
          sha, name = line.split
          Ref.new(@repo, sha, name)
        end
      end

      def find_by_sha(sha)
        all.detect do |ref|
          ref.sha == sha
        end
      end

      # name = refs/autotags/2009857463
      # returns a ref
      # should un-cache the refs in refset, or never memoize
      def create(sha, name)
        Ref.new(@repo, sha, name).save
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

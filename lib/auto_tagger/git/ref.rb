module AutoTagger
  module Git
    class Ref
      attr_reader :repo, :sha, :name

      # name is refs/autotags/2009292827
      def initialize(repo, sha, name)
        @repo, @sha, @name = repo, sha, name
      end

      def delete
        repo.exec "update-ref -d #{name}"
      end

      def save
        repo.exec "update-ref #{name} #{sha}"
        self
      end

      def delete_remote
        repo.exec "push origin :#{name}"
      end
    end
  end
end

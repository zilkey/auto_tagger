module AutoTagger
  module Git
    class Ref
      attr_reader :sha, :name

      # name is refs/autotags/2009292827
      def initialize(repo, sha, name)
        @repo, @sha, @name = repo, sha, name
      end

      def delete_locally
        @repo.exec "update-ref -d #{name}"
      end

      def delete_on_remote
        @repo.exec "push origin :#{name}"
      end

      def save
        @repo.exec "update-ref #{name} #{sha}"
        self
      end

    end
  end
end

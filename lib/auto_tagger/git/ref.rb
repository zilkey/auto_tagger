module AutoTagger
  module Git
    class Ref
      attr_reader :repo, :sha, :name

      def initialize(repo, sha, name)
        @repo, @sha, @name = repo, sha, name
      end

      def delete
        repo.exec "update-ref -d #{name}"
      end
    end
  end
end

module AutoTagger
  class StageCannotBeBlankError < StandardError;
  end

  def self.version
    File.read(File.expand_path(File.join(__FILE__, "/../../../VERSION")))
  end

  class Base
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def repo
      @repo ||= AutoTagger::Git::Repo.new(options[:path])
    end

    def create_ref(commit = nil)
      ensure_stage
      repo.refs.fetch if options[:fetch_refs]
      new_tag = repo.refs.create(ref_name, commit)
      repo.ref.push if options[:push_refs]
      new_tag
    end

    def latest_ref
      ensure_stage
      repo.tags.fetch
      repo.tags.latest_from(stage)
    end

    private

    def ref_name
      # formatted ref with correct path and timestamp
    end

    def stage
      options[:stage]
    end

    def ensure_stage
      raise StageCannotBeBlankError if stage.to_s.strip == ""
    end
  end
end
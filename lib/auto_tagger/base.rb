module AutoTagger
  class StageCannotBeBlankError < StandardError; end

  def self.version
    File.read(File.expand_path(File.join(__FILE__, "/../../../VERSION")))
  end

  class Base
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def repository
      @repository ||= Repository.new(options[:path])
    end

    def create_ref(commit = nil)
      ensure_stage
      repository.tags.fetch
      new_tag = repository.tags.create(stage, commit)
      repository.tags.push
      new_tag
    end

    def latest_tag
      ensure_stage
      repository.tags.fetch
      repository.tags.latest_from(stage)
    end

    private

    def stage
      configuration.stage
    end

    def ensure_stage
      raise StageCannotBeBlankError if stage.to_s.strip == ""
    end
  end
end
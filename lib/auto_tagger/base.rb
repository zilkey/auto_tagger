module AutoTagger
  class StageCannotBeBlankError < StandardError; end

  def self.version
    File.read(File.expand_path(File.join(__FILE__, "/../../../VERSION")))
  end

  class Runner
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def repository
      @repository ||= Repository.new(configuration)
    end

    def create_tag(commit = nil)
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
module AutoTagger
  class StageCannotBeBlankError < StandardError; end
  
  class Runner
    attr_reader :stage, :repository, :working_directory

    def initialize(stage, path = nil)
      raise StageCannotBeBlankError if stage.to_s.strip == ""
      @working_directory = File.expand_path(path ||= Dir.pwd)
      @repository = Repository.new(@working_directory)
      @stage = stage
    end

    def create_tag(commit = nil)
      repository.tags.fetch
      new_tag = repository.tags.create(stage, commit)
      repository.tags.push
      new_tag
    end

    def latest_tag
      repository.tags.fetch
      repository.tags.latest_from(stage)
    end
  end
end
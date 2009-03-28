class AutoTagger

  class EnvironmentCannotBeBlankError < StandardError; end

  attr_reader :stage, :repository, :working_directory

  def initialize(stage, path = nil)
    raise EnvironmentCannotBeBlankError if stage.to_s.strip == ""
    @working_directory = File.expand_path(path ||= Dir.pwd)
    @repository = Repository.new(@working_directory)
    @stage = stage
  end

  def create_tag
    repository.tags.fetch
    new_tag = repository.tags.create(stage)
    repository.tags.push
    new_tag
  end

  def latest_tag
    repository.tags.fetch
    repository.tags.latest_from(stage)
  end

end

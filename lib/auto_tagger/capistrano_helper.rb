module AutoTagger
  class CapistranoHelper

    attr_reader :variables, :stage, :working_directory

    def initialize(variables)
      @stage_manager = StageManager.new(variables[:autotagger_stages])
      @variables = variables
      @stage = variables[:stage]
      @working_directory = variables[:working_directory] || Dir.pwd
    end

    def previous_stage
      @stage_manager.previous_stage(stage)
    end

    def branch
      if variables.has_key?(:head)
        variables[:branch]
      elsif variables.has_key?(:tag)
        variables[:tag]
      elsif previous_stage && (latest = Runner.new(previous_stage, working_directory).latest_tag)
        latest
      else
        variables[:branch]
      end
    end

    def release_tag_entries
      entries = []
      @stage_manager.stages.each do |stage|
        tagger = Runner.new(stage, working_directory)
        tag = tagger.latest_tag
        commit = tagger.repository.commit_for(tag)
        entries << "#{stage.to_s.ljust(10, " ")} #{tag.to_s.ljust(30, " ")} #{commit.to_s}"
      end
      entries
    end

  end
end
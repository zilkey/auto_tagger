class CapistranoHelper

  attr_reader :variables, :current_stage, :working_directory

  def initialize(variables)
    @stage_manager = StageManager.new(variables[:stages])
    @variables = variables
    @current_stage = variables[:current_stage]
    @working_directory = variables[:working_directory] || Dir.pwd
  end

  def previous_stage
    @stage_manager.previous_stage(current_stage)
  end

  def branch
    if variables.has_key?(:head)
      variables[:branch]
    elsif variables.has_key?(:tag)
      variables[:tag]
    elsif previous_stage && (latest = AutoTagger.new(previous_stage, working_directory).latest_tag)
      latest
    else
      variables[:branch]
    end
  end

end
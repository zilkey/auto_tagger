class CapistranoHelper

  class NoStagesSpecifiedError < StandardError
    def message
      "You must set the :stages variable to an array, like set :stages, [:ci, :demo]"
    end
  end
  
  attr_reader :variables, :stages, :current_stage, :working_directory

  def initialize(variables)
    raise NoStagesSpecifiedError unless variables[:stages]
    @variables = variables
    @stages = variables[:stages]
    @current_stage = variables[:current_stage]
    @working_directory = variables[:working_directory] || Dir.pwd
  end

  def previous_stage
    if current_stage
      index = stages.index(current_stage) - 1
      stages[index] if index > -1 
    end
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
class StageManager

  class NoStagesSpecifiedError < StandardError
    def message
      "You must set the :stages variable to an array, like set :stages, [:ci, :demo]"
    end
  end

  attr_reader :stages

  def initialize(stages)
    raise NoStagesSpecifiedError unless stages && stages.is_a?(Array)
    @stages = stages.map{|stage| stage.to_s }
  end

  def previous_stage(stage)
    if stage
      index = stages.index(stage.to_s) - 1
      stages[index] if index > -1
    end
  end

end

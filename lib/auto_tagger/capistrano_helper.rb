module AutoTagger
  class CapistranoHelper

    attr_reader :variables, :configuration

    class Dsl
      attr_reader :cap

      def initialize(cap)
        @cap = cap
      end

      def stages(array)
        cap.set :auto_tagger_stages, array
      end

      def date_format(string)
        cap.set :auto_tagger_date_format, string
      end
    end

    def initialize(variables)
      @variables = variables

      if variables[:working_directory]
        AutoTagger::Deprecator.warn(":working_directory is deprecated.  Please use :auto_tagger_working_directory or see the readme for the new api.")
      end

      if stages = variables.delete(:stages)
        variables[:auto_tagger_stages] = stages
        AutoTagger::Deprecator.warn(":stages is deprecated.  Please use :auto_tagger_stages or see the readme for the new api.")
      end

      @options = {}
      @options[:stage] = variables[:auto_tagger_stage] || variables[:stage]
      @options[:path] = variables[:auto_tagger_working_directory] || variables[:working_directory]
      @options[:date_format] = variables[:auto_tagger_date_format]
      @options[:push_refs] = variables[:auto_tagger_push_refs]
      @options[:fetch_refs] = variables[:auto_tagger_fetch_refs]
      @options[:ref_prefix] = variables[:auto_tagger_ref_prefix]
      @configuration = AutoTagger::Configuration.new(@options)
    end

    def stage_manager
      @stage_manager ||= StageManager.new(@variables[:auto_tagger_stages])
    end

    def previous_stage
      stage_manager.previous_stage(@configuration.stage)
    end

    def previous_configuration
      AutoTagger::Configuration.new :stage => previous_stage,
                                    :path => configuration.working_directory
    end

    # should be Ref
    def branch
      if variables.has_key?(:head)
        variables[:branch]
      elsif variables.has_key?(:tag)
        variables[:tag]
      elsif previous_stage && (latest = Runner.new(previous_configuration).latest_tag)
        latest
      else
        variables[:branch]
      end
    end

    def release_tag_entries
      entries = []
      stage_manager.stages.each do |stage|
        configuration = AutoTagger::Configuration.new :stage => stage, :path => @configuration.working_directory
        tagger = Runner.new(configuration)
        tag = tagger.latest_tag
        commit = tagger.repository.commit_for(tag)
        entries << "#{stage.to_s.ljust(10, " ")} #{tag.to_s.ljust(30, " ")} #{commit.to_s}"
      end
      entries
    end

  end
end
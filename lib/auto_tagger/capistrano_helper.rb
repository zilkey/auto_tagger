module AutoTagger
  class CapistranoHelper

    def initialize(variables)
      @variables = variables
    end

    # TODO: use fetch here
    def ref
      if @variables.has_key?(:head)
        @variables[:branch] # shouldn't this be HEAD??
      elsif @variables.has_key?(:tag)
        @variables[:tag]
      elsif @variables.has_key?(:ref)
        @variables[:ref]
      elsif auto_tagger.last_tag_from_previous_stage
        auto_tagger.last_tag_from_previous_stage.sha
      else
        @variables[:branch]
      end
    end

    def auto_tagger
      return @auto_tagger if @auto_tagger

      if @variables[:working_directory]
        AutoTagger::Deprecator.warn(":working_directory is deprecated.  Please use :auto_tagger_working_directory or see the readme for the new api.")
      end

      if stages = @variables.delete(:stages)
        @variables[:auto_tagger_stages] = stages
        AutoTagger::Deprecator.warn(":stages is deprecated.  Please use :auto_tagger_stages or see the readme for the new api.")
      end

      options = {}
      options[:stage] = @variables[:auto_tagger_stage] || @variables[:stage]
      options[:stages] = (@variables[:auto_tagger_stages] || @variables[:autotagger_stages] || @variables[:stages] || []).map{|stage| stage.to_s}.join(",")
      options[:path] = @variables[:auto_tagger_working_directory] || @variables[:working_directory]
      options[:date_format] = @variables[:auto_tagger_date_format]
      options[:push_refs] = @variables[:auto_tagger_push_refs]
      options[:fetch_refs] = @variables[:auto_tagger_fetch_refs]
      options[:remote] = @variables[:auto_tagger_remote]
      options[:ref_path] = @variables[:auto_tagger_ref_path]
      # todo: add all other options here

      @auto_tagger ||= AutoTagger::Base.new(options)
    end

  end
end
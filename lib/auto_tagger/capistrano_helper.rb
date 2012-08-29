module AutoTagger
  class CapistranoHelper

    attr_reader :variables
    private :variables

    def initialize(variables)
      @variables = variables
    end

    def auto_tagger
      @auto_tagger ||= AutoTagger::Base.new(auto_tagger_options)
    end

    def ref
      if variables.has_key?(:head)
        variables[:branch]
      elsif variables.has_key?(:tag)
        variables[:tag]
      elsif variables.has_key?(:ref)
        variables[:ref]
      elsif auto_tagger.last_ref_from_previous_stage
        auto_tagger.last_ref_from_previous_stage.sha
      else
        variables[:branch]
      end
    end

    def auto_tagger_options
      options = {}
      options[:stage] = variables[:auto_tagger_stage] || variables[:stage]
      options[:stages] = stages

      if variables[:working_directory]
        AutoTagger::Deprecator.warn(":working_directory is deprecated.  Please use :auto_tagger_working_directory.")
        options[:path] = variables[:working_directory]
      else
        options[:path] = variables[:auto_tagger_working_directory]
      end

      if ! variables[:auto_tagger_dry_run].nil?
        options[:dry_run] = variables[:auto_tagger_dry_run]
      else
        options[:dry_run] = variables[:dry_run] if variables.has_key?(:dry_run)
      end

      [
        :date_separator, :push_refs, :fetch_refs, :remote, :ref_path, :offline,
        :verbose, :refs_to_keep, :executable, :opts_file
      ].each do |key|
        options[key] = variables[:"auto_tagger_#{key}"] if variables.has_key?(:"auto_tagger_#{key}")
      end

      options
    end

    def stages
      if variables[:autotagger_stages]
        AutoTagger::Deprecator.warn(":autotagger_stages is deprecated.  Please use :auto_tagger_stages.")
        stages = variables[:autotagger_stages]
      else
        stages = variables[:auto_tagger_stages] || variables[:stages] || []
      end
      stages.map { |stage| stage.to_s }
    end

  end
end

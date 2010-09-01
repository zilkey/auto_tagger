module AutoTagger
  class StageCannotBeBlankError < StandardError;
  end

  def self.version
    File.read(File.expand_path(File.join(__FILE__, "/../../../VERSION")))
  end

  class Base
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def stages
      @stages = stages.map { |stage| stage.to_s }
    end

    def repo
      @repo ||= AutoTagger::Git::Repo.new(options[:path])
    end

    #    configuration = AutoTagger::Configuration.new :stage => variables[:stage],
    #                                                  :path => variables[:working_directory]
    #    tag_name = AutoTagger::Runner.new(configuration).create_ref(real_revision)
    #
    #   OR
    #
    #    configuration = AutoTagger::Configuration.new :stage => :production,
    #                                                  :path => variables[:working_directory]
    #    tag_name = AutoTagger::Runner.new(configuration).create_ref

    def create_ref(commit = nil)
      ensure_stage
      repo.refs.fetch if options[:fetch_refs]
      new_tag = repo.refs.create(ref_name, commit)
      repo.ref.push if options[:push_refs]
      new_tag
    end

    def latest_ref
      ensure_stage
      repo.tags.fetch
      repo.tags.latest_from(stage)
    end

    def release_tag_entries
      entries = []
      stage_manager.stages.each do |stage|
        configuration = AutoTagger::Configuration.new :stage => stage, :path => @configuration.working_directory
        tagger = Runner.new(configuration)
        tag = tagger.latest_ref
        commit = tagger.repository.commit_for(tag)
        entries << "#{stage.to_s.ljust(10, " ")} #{tag.to_s.ljust(30, " ")} #{commit.to_s}"
      end
      entries
    end

    private

    def ref_name
      # formatted ref with correct path and timestamp
    end

    def stage
      options[:stage]
    end

    def ensure_stage
      raise StageCannotBeBlankError if stage.to_s.strip == ""
    end
  end
end
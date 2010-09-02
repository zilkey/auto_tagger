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

    def repo
      @repo ||= AutoTagger::Git::Repo.new configuration.working_directory,
                                          :execute_commands => !configuration.dry_run?,
                                          :verbose => configuration.verbose?,
                                          :executable => configuration.executable
    end

    def last_tag_from_previous_stage
      previous_stage = if configuration.stage
        index = configuration.stages.index(configuration.stage).to_i - 1
        configuration.stages[index] if index > -1
      end

      if previous_stage
        stage_regexp = Regexp.escape(previous_stage)
        refs = repo.refs.all.select do |ref|
          regexp = /refs\/#{Regexp.escape(configuration.ref_path)}\/(#{stage_regexp})\/.*/
          (ref.name =~ regexp) ? ref : nil
        end
        refs.last
      end
    end

    def create_ref(commit = nil)
      commit ||= repo.latest_commit_sha
      ensure_stage
      repo.refs.fetch("refs/#{configuration.ref_path}/*", configuration.remote) if configuration.fetch_refs?
      new_tag = repo.refs.create(ref_name, commit)
      repo.refs.push("refs/#{configuration.ref_path}/*", configuration.remote) if configuration.push_refs?
      new_tag
    end

    def cleanup
      stage_regexp = Regexp.escape(configuration.stage)
      refs = repo.refs.all.select do |ref|
        regexp = /refs\/#{Regexp.escape(configuration.ref_path)}\/(#{stage_regexp})\/.*/
        (ref.name =~ regexp) ? ref : nil
      end

      refs = refs[(configuration.refs_to_keep)..-1]

      refs.each do |ref|
        ref.delete_locally
        ref.delete_on_remote(configuration.remote) if configuration.push_refs?
      end
      refs.length
    end

    def list
      stage_regexp = Regexp.escape(configuration.stage)
      repo.refs.all.select do |ref|
        regexp = /refs\/#{Regexp.escape(configuration.ref_path)}\/(#{stage_regexp})\/.*/
        (ref.name =~ regexp) ? ref : nil
      end
    end

    def latest_ref
      ensure_stage
      repo.tags.fetch
      repo.tags.latest_from(stage)
    end

    def release_tag_entries
      entries = []
      configuration.stages.each do |stage|
        configuration = AutoTagger::Configuration.new :stage => stage, :path => @configuration.working_directory
        tagger = Base.new(configuration)
        tag = tagger.latest_ref
        commit = tagger.repository.commit_for(tag)
        entries << "#{stage.to_s.ljust(10, " ")} #{tag.to_s.ljust(30, " ")} #{commit.to_s}"
      end
      entries
    end

    private

    def configuration
      @configuration ||= begin
        config = AutoTagger::Configuration.new(@options)
        # raise "Stage must be included in stages" unless config.stages.include?(config.stage)
        config
      end
    end

    def ref_name
      "refs/#{configuration.ref_path}/#{configuration.stage}/#{Time.now.utc.strftime(configuration.date_format)}"
    end

    def ensure_stage
      raise StageCannotBeBlankError if configuration.stage.to_s.strip == ""
    end
  end
end
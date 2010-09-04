module AutoTagger

  def self.version
    File.read(File.expand_path(File.join(__FILE__, "/../../../VERSION")))
  end

  class Base
    class StageCannotBeBlankError < StandardError;
    end

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

    def last_ref_from_previous_stage
      return unless previous_stage
      ref_path = Regexp.escape(configuration.ref_path)
      stage = Regexp.escape(previous_stage)
      matcher = /refs\/#{ref_path}\/(#{stage})\/.*/
      repo.refs.all.select do |ref|
        (ref.name =~ matcher) ? ref : nil
      end.last
    end

    def create_ref(commit = nil)
      ensure_stage
      pattern = "refs/#{configuration.ref_path}/*"
      repo.refs.fetch(pattern, configuration.remote) if configuration.fetch_refs?
      new_tag = repo.refs.create(commit || repo.latest_commit_sha, ref_name)
      repo.refs.push(pattern, configuration.remote) if configuration.push_refs?
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

    def previous_stage
      return unless configuration.stage
      index = configuration.stages.index(configuration.stage).to_i - 1
      configuration.stages[index] if index > -1
    end

    def configuration
      @configuration ||= begin
        config = AutoTagger::Configuration.new(@options)
        # raise "Stage must be included in stages" unless config.stages.include?(config.stage)
        config
      end
    end

    def ref_name
      "refs/#{configuration.ref_path}/#{configuration.stage}/#{timestamp}"
    end

    def timestamp
      time = Time.now.utc
      [
        time.strftime("%Y"),
        time.strftime("%m"),
        time.strftime("%d"),
        time.strftime("%H"),
        time.strftime("%M"),
        time.strftime("%S")
      ].join(configuration.date_separator)
    end

    def ensure_stage
      raise StageCannotBeBlankError if configuration.stage.to_s.strip == ""
    end
  end
end
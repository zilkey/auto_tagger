module AutoTagger

  def self.version
    File.read(File.expand_path(File.join(__FILE__, "/../../../VERSION")))
  end

  class Base
    class StageCannotBeBlankError < StandardError;
    end

    def self.items_to_remove(array, keep)
      max = array.length - keep
      max = 0 if max <= 0
      array[0...max]
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
      refs_for_stage(previous_stage).last
    end

    def create_ref(commit = nil)
      ensure_stage
      fetch
      new_tag = repo.refs.create(commit || repo.latest_commit_sha, ref_name)
      push
      new_tag
    end

    def pattern
      "refs/#{configuration.ref_path}/*"
    end

    private :pattern

    def fetch
      repo.refs.fetch(pattern, configuration.remote) if configuration.fetch_refs?
    end

    private :fetch

    def push
      repo.refs.push(pattern, configuration.remote) if configuration.push_refs?
    end

    private :push

    def cleanup
      length = delete_locally
      delete_on_remote if configuration.push_refs?
      return length
    end

    def delete_locally
      refs = refs_to_remove
      refs.each { |ref| ref.delete_locally }
      refs.length
    end

    def delete_on_remote
      refs = refs_to_remove
      cmd = ["push #{configuration.remote}"]
      cmd += refs.map { |ref| ":#{ref.name}" }
      repo.exec cmd.join(" ")
      refs.length
    end

    def list
      ensure_stage
      fetch
      refs_for_stage(configuration.stage)
    end

    def release_tag_entries
      configuration.stages.map do |stage|
        refs_for_stage(stage).last
      end
    end

    def refs_for_stage(stage)
      ref_path = Regexp.escape(configuration.ref_path)
      matcher = /refs\/#{ref_path}\/#{Regexp.escape(stage)}\/.*/
      repo.refs.all.select do |ref|
        (ref.name =~ matcher) ? ref : nil
      end
    end

    private

    def refs_to_remove
      self.class.items_to_remove(refs_for_stage(configuration.stage), configuration.refs_to_keep)
    end

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
# git --no-pager log --pretty=oneline -1
# git tag -a -m 'Successful continuous integration build on #{timestamp}' #{tag_name}"
module AutoTagger
  class Tag

    attr_reader :repository

    def initialize(repository)
      @repository = repository
    end

    def find_all
      run("git tag").split("\n")
    end

    def fetch
      run!("git fetch origin --tags") if fetch_refs?
    end

    def latest_from(stage)
      find_all.select{|tag| tag =~ /^#{stage}\//}.sort.last
    end

    def push
      run!("git push origin --tags") if push_refs?
    end

    def create(stage, commit = nil)
      tag_name = name_for(stage)
      cmd = "git tag #{tag_name}"
      cmd += " #{commit}" if commit
      repository.run! cmd
      tag_name
    end

    private

    def run(cmd)
      repository.run cmd
    end

    def run!(cmd)
      repository.run! cmd
    end

    def configuration
      repository.configuration
    end

    def fetch_refs?
      configuration.fetch_refs?
    end

    def push_refs?
      configuration.push_refs?
    end

    def ref_prefix
      configuration.ref_prefix
    end

    def date_format
      configuration.date_format
    end

    def name_for(stage)
      "%s%s%s" % [stage, ref_prefix, Time.now.utc.strftime(date_format)]
    end

  end
end
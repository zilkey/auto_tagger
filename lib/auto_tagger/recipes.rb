require File.expand_path(File.join(File.dirname(__FILE__), "..", "auto_tagger"))

Capistrano::Configuration.instance(:must_exist).load do

  def auto_tagger(&block)
    AutoTagger::CapistranoHelper::Configuration.configure(self, &block)
  end

  namespace :release_tagger do
    desc %Q{
      Sets the branch to the latest tag from the previous stage.
      Use -Shead=true to set the branch to master, -Stag=<tag> to specify the tag explicitly.
    }
    task :set_branch do
      if branch_name = AutoTagger::CapistranoHelper.new(variables).branch
        set :branch, branch_name
        logger.info "setting branch to #{branch_name}"
      else
        logger.info "AUTO TAGGER: skipping auto-assignment of branch.  Branch will remain the default.}"
      end
    end

    desc %Q{Prints the most current tags from all stages}
    task :print_latest_tags, :roles => :app do
      logger.info "AUTO TAGGER: release tag history is:"
      entries = AutoTagger::CapistranoHelper.new(variables).release_tag_entries
      entries.each do |entry|
        logger.info entry
      end
    end

    desc %Q{Reads the text file with the latest tag from the shared directory}
    task :read_tag_from_shared, :roles => :app do
      logger.info "AUTO TAGGER: latest tag deployed to this environment was:"
      run "cat #{shared_path}/released_git_tag.txt"
    end

    desc %Q{Writes the tag name to a file in the shared directory}
    task :write_tag_to_shared, :roles => :app do
      if exists?(:branch)
        logger.info "AUTO TAGGER: writing tag to shared text file on remote server"
        run "echo '#{branch}' > #{shared_path}/released_git_tag.txt"
      else
        logger.info "AUTO TAGGER: no branch available.  Text file was not written to server"
      end
    end

    desc %Q{Creates a tag using the stage variable}
    task :create_tag, :roles => :app do
      if variables[:stage]
        configuration = AutoTagger::Configuration.new :stage => variables[:stage],
                                                      :path => variables[:working_directory]
        tag_name = AutoTagger::Runner.new(configuration).create_tag(real_revision)
        logger.info "AUTO TAGGER created tag #{tag_name} from #{real_revision}"
      else
        configuration = AutoTagger::Configuration.new :stage => :production,
                                                      :path => variables[:working_directory]
        tag_name = AutoTagger::Runner.new(configuration).create_tag
        logger.info "AUTO TAGGER created tag #{tag_name}"
      end
    end
  end
end

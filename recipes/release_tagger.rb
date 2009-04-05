require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "auto_tagger"))

Capistrano::Configuration.instance(:must_exist).load do
  namespace :release_tagger do
    desc %Q{
      Sets the branch to the latest tag from the previous stage.
      Use -Shead=true to set the branch to master, -Stag=<tag> to specify the tag explicitly.
    }
    task :set_branch do
      if branch_name = CapistranoHelper.new(variables).branch
        set :branch, branch_name
        logger.info "setting branch to #{branch_name}"
      else
        logger.info "AUTO TAGGER: skipping auto-assignment of branch.  Branch will remain the default.}"
      end
    end

    desc %Q{Prints the most current tags from all stages}
    task :print_latest_tags, :roles => :app do
      logger.info "AUTO TAGGER: release tag history is:"
      entries = CapistranoHelper.new(variables).release_tag_entries
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
        previous_tag = AutoTagger.new(StageManager.new(autotagger_stages).previous_stage(stage), Dir.pwd).latest_tag
        tag_name = AutoTagger.new(variables[:stage], variables[:working_directory]).create_tag(previous_tag)
        logger.info "AUTO TAGGER created tag #{tag_name} from #{previous_tag.inspect}"
      else
        logger.info "AUTO TAGGER WARNING: skipping auto-creation of tag.  Please specify :stage to enable auto-creation of tags (like set :stage, :ci)."
      end
    end
  end
end

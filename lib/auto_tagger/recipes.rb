require File.expand_path(File.join(File.dirname(__FILE__), "..", "auto_tagger"))

Capistrano::Configuration.instance(:must_exist).load do

  namespace :auto_tagger do

    def auto_tagger_capistrano_helper
      AutoTagger::CapistranoHelper.new(variables)
    end

    def auto_tagger
      auto_tagger_capistrano_helper.auto_tagger
    end
    
    def log_auto_tagger(message)
      logger.info "AUTO TAGGER: #{message}"
    end

    desc %Q{
      Sets the branch to the latest tag from the previous stage.
      Use -Shead=true to set the branch to master, 
      -Stag=<tag> or -Sref=<ref> to specify the tag explicitly.
    }
    task :set_branch do
      if ref = auto_tagger_capistrano_helper.ref
        set :branch, ref
        log_auto_tagger "setting branch to #{ref.name}"
      else
        log_auto_tagger "skipping auto-assignment of branch.  Branch will remain the default.}"
      end
    end

    desc %Q{Creates a tag using the stage variable}
    task :create_ref, :roles => :app do
      if variables[:stage]
        ref = auto_tagger.create_ref(real_revision)
        log_auto_tagger "created tag #{ref.name} from #{ref.sha}"
      else
        ref = auto_tagger.create_ref
        log_auto_tagger "created tag #{ref.name}"
      end
    end
    
    desc %Q{DEPRECATED: Prints the most current tags from all stages}
    task :print_latest_refs, :roles => :app do
      log_auto_tagger "release tag history is:"
      auto_tagger.release_tag_entries.each { |entry| logger.info entry }
    end

    desc %Q{DEPRECATED: Reads the text file with the latest tag from the shared directory}
    task :read_tag_from_shared, :roles => :app do
      log_auto_tagger "latest tag deployed to this environment was:"
      run "cat #{shared_path}/released_git_tag.txt"
    end

    desc %Q{DEPRECATED: Writes the tag name to a file in the shared directory}
    task :write_tag_to_shared, :roles => :app do
      if exists?(:branch)
        log_auto_tagger "writing tag to shared text file on remote server"
        run "echo '#{branch}' > #{shared_path}/released_git_tag.txt"
      else
        log_auto_tagger "no branch available.  Text file was not written to server"
      end
    end
  end

  #TODO: alias release_tagger to auto_tagger

end

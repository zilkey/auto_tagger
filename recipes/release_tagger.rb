require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "auto_tagger"))

Capistrano::Configuration.instance(:must_exist).load do
  namespace :release_tagger do
    desc %Q{
      Sets the branch to the latest tag from the previous stage.  
      Use -Shead=true to set the branch to master, -Stag=<tag> to specify the tag explicitly.
    }
    task :set_branch do
      branch_name = CapistranoHelper.new(variables).branch
      set :branch, branch_name
      logger.info "setting branch to #{branch_name.inspect}"
    end

    desc %Q{Creates a tag using the current_stage variable}
    task :create_tag do
      if variables[:current_stage]
        tag_name = AutoTagger.new(variables[:current_stage], variables[:working_directory]).create_tag
        logger.info "created and pushed tag #{tag_name}"
      else
        logger.info "AUTO TAGGER WARNING: skipping auto-creation of tag.  Please specify :current_stage to enable auto-creation of tags (like set :current_stage, :ci)."
      end
    end
  end
end


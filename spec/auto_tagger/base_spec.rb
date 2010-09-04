require 'spec_helper'

describe AutoTagger::Base do

  describe "#repo" do
    it "returns a repo with the correct options" do
      base = AutoTagger::Base.new :path => "/foo",
                                  :dry_run => true,
                                  :verbose => true,
                                  :executable => "/usr/bin/git"
      AutoTagger::Git::Repo.should_receive(:new).with "/foo",
                                                      :execute_commands => false,
                                                      :verbose => true,
                                                      :executable => "/usr/bin/git"
      base.repo
    end
  end

  describe "#last_ref_from_previous_stage" do
    it "returns nil if there is no previous stage" do
      refs = "0f7324495f06e2b refs/tags/ci/2001"
      base = AutoTagger::Base.new :stages => ["ci", "demo", "production"], :stage => "ci"
      base.repo.stub(:read).and_return(refs)
      base.last_ref_from_previous_stage.should be_nil
    end

    it "returns nil if there are no matching refs" do
      refs = "0f7324495f06e2b refs/tags-ci/2001"
      base = AutoTagger::Base.new :stages => ["ci", "demo", "production"], :stage => "ci"
      base.repo.stub(:read).and_return(refs)
      base.last_ref_from_previous_stage.should be_nil
    end

    it "should return the last ref from the previous stage" do
      refs = %Q{
        41dee06050450ac refs/tags/ci/2003
        41dee06050450a5 refs/tags/ci/2003
        61c6627d766c1be refs/tags/demo/2001
      }
      base = AutoTagger::Base.new :stages => ["ci", "demo", "production"], :stage => "demo"
      base.repo.stub(:read).and_return(refs)
      ref = AutoTagger::Git::Ref.new(base.repo, "41dee06050450ac", "refs/tags/ci/2003")
      base.last_ref_from_previous_stage.name.should == "refs/tags/ci/2003"
    end
  end

  describe "#create_ref" do
    it "creates a ref with the given sha and returns the ref" do
      base = AutoTagger::Base.new :stages => ["ci", "demo", "production"], :stage => "demo"
      base.stub(:timestamp).and_return("20081010")

      base.repo.stub(:exec) { true }
      base.repo.should_receive(:exec).with("update-ref refs/tags/demo/20081010 abc123")

      ref = base.create_ref "abc123"
      ref.name.should == "refs/tags/demo/20081010"
      ref.sha.should == "abc123"
    end

    it "defaults to the latest commit sha" do
      base = AutoTagger::Base.new :stages => ["ci", "demo", "production"], :stage => "demo"
      base.stub(:timestamp).and_return("20081010")

      base.repo.should_receive(:latest_commit_sha).and_return("abc123")
      base.repo.stub(:exec) { true }
      base.repo.should_receive(:exec).with("update-ref refs/tags/demo/20081010 abc123")

      ref = base.create_ref
      ref.name.should == "refs/tags/demo/20081010"
      ref.sha.should == "abc123"
    end

    it "respects the passed in date separator" do
      time = Time.now.utc
      timestamp = time.strftime("%Y-%m-%d-%H-%M-%S")
      base = AutoTagger::Base.new :stages => ["ci"], :stage => "ci", :date_separator => "-"
      base.repo.stub(:exec) { true }
      base.repo.should_receive(:exec).with("update-ref refs/tags/ci/#{timestamp} abc123")
      base.create_ref "abc123"
    end

    it "raises an error if the stage is not set" do
      proc do
        AutoTagger::Base.new({}).create_ref
      end.should raise_error(AutoTagger::Base::StageCannotBeBlankError)
    end

    it "fetches tags before creating tags" do
      base = AutoTagger::Base.new :stages => ["ci"], :stage => "ci"
      base.repo.stub(:exec) { true }
      base.repo.should_receive(:exec).with("fetch origin refs/tags/*:refs/tags/*")
      base.create_ref "abc123"
    end

    it "does not fetch tags before creating tags if fetch tags is false" do
      base = AutoTagger::Base.new :stages => ["ci"], :stage => "ci", :fetch_tags => false
      base.repo.stub(:exec) { true }
      base.repo.should_receive(:exec).with("push origin refs/tags/*:refs/tags/*")
      base.create_ref "abc123"
    end

    it "pushes tags before creating tags" do
      base = AutoTagger::Base.new :stages => ["ci"], :stage => "ci"
      base.repo.stub(:exec) { true }
      base.repo.should_receive(:exec).with("push origin refs/tags/*:refs/tags/*")
      base.create_ref "abc123"
    end

    it "does not push tags before creating tags if push tags is false" do
      base = AutoTagger::Base.new :stages => ["ci"], :stage => "ci", :push_tags => false
      base.repo.stub(:exec) { true }
      base.repo.should_receive(:exec).with("push origin refs/tags/*:refs/tags/*")
      base.create_ref "abc123"
    end
  end

#  describe "#cleanup" do
#    it "should do something" do
#      stage_regexp = Regexp.escape(configuration.stage)
#      refs = repo.refs.all.select do |ref|
#        regexp = /refs\/#{Regexp.escape(configuration.ref_path)}\/(#{stage_regexp})\/.*/
#        (ref.name =~ regexp) ? ref : nil
#      end
#
#      refs = refs[(configuration.refs_to_keep)..-1]
#
#      refs.each do |ref|
#        ref.delete_locally
#        ref.delete_on_remote(configuration.remote) if configuration.push_refs?
#      end
#      refs.length
#    end
#  end
#
#  describe "#list" do
#    it "should do something" do
#      stage_regexp = Regexp.escape(configuration.stage)
#      repo.refs.all.select do |ref|
#        regexp = /refs\/#{Regexp.escape(configuration.ref_path)}\/(#{stage_regexp})\/.*/
#        (ref.name =~ regexp) ? ref : nil
#      end
#    end
#  end
#
#  describe "#latest_ref" do
#    it "should do something" do
#      ensure_stage
#      repo.tags.fetch
#      repo.tags.latest_from(stage)
#    end
#  end
#
#  describe "#release_tag_entries" do
#    it "should do something" do
#      entries = []
#      configuration.stages.each do |stage|
#        configuration = AutoTagger::Configuration.new :stage => stage, :path => @configuration.working_directory
#        tagger = Base.new(configuration)
#        tag = tagger.latest_ref
#        commit = tagger.repository.commit_for(tag)
#        entries << "#{stage.to_s.ljust(10, " ")} #{tag.to_s.ljust(30, " ")} #{commit.to_s}"
#      end
#      entries
#    end
#  end
#
#
end

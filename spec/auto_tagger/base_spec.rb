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

    it "should return the last ref with correct order (git show-ref is not ordered)" do
      refs = %Q{
        a80af49962c95a92df59a527a3ce60e22da290fc refs/tags/ci/1002
        0e892ad1b308dd86c40f5fd60b3cddd58022d93e refs/tags/ci/997
        b8d7ce86f1c6440080e0c315c7cc1c0fe702127f refs/tags/ci/999
      }
      base = AutoTagger::Base.new :stages => ["ci", "demo", "production"], :stage => "demo"
      base.repo.stub(:read).and_return(refs)
      ref = AutoTagger::Git::Ref.new(base.repo, "a80af49962c95a92df59a527a3ce60e22da290fc", "refs/tags/ci/1002")
      base.last_ref_from_previous_stage.name.should == "refs/tags/ci/1002"
    end
  end

  describe "#create_ref" do
    it "creates a ref with the given sha and returns the ref" do
      base = AutoTagger::Base.new :stage => "demo"
      base.stub(:timestamp).and_return("20081010")

      base.repo.stub(:exec) { true }
      base.repo.should_receive(:exec).with("update-ref refs/tags/demo/20081010 abc123")

      ref = base.create_ref "abc123"
      ref.name.should == "refs/tags/demo/20081010"
      ref.sha.should == "abc123"
    end

    it "defaults to the latest commit sha" do
      base = AutoTagger::Base.new :stage => "demo"
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
      base = AutoTagger::Base.new :stage => "ci", :date_separator => "-"
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
      base = AutoTagger::Base.new :stage => "ci"
      base.repo.stub(:exec) { true }
      base.repo.should_receive(:exec).with("fetch origin refs/tags/*:refs/tags/*")
      base.create_ref "abc123"
    end

    it "does not fetch tags before creating tags if fetch tags is false" do
      base = AutoTagger::Base.new :stage => "ci", :fetch_tags => false
      base.repo.stub(:exec) { true }
      base.repo.should_receive(:exec).with("push origin refs/tags/*:refs/tags/*")
      base.create_ref "abc123"
    end

    it "pushes tags before creating tags" do
      base = AutoTagger::Base.new :stage => "ci"
      base.repo.stub(:exec) { true }
      base.repo.should_receive(:exec).with("push origin refs/tags/*:refs/tags/*")
      base.create_ref "abc123"
    end

    it "does not push tags before creating tags if push tags is false" do
      base = AutoTagger::Base.new :stage => "ci", :push_tags => false
      base.repo.stub(:exec) { true }
      base.repo.should_receive(:exec).with("push origin refs/tags/*:refs/tags/*")
      base.create_ref "abc123"
    end
  end

  describe "#delete_locally" do
    it "blows up if you don't enter a stage" do
      base = AutoTagger::Base.new({})
      proc do
        base.delete_locally
      end.should raise_error(AutoTagger::Base::StageCannotBeBlankError)
    end

    it "executes the local delete commands for all the refs that match" do
      base = AutoTagger::Base.new :stage => "ci"
      base.repo.stub(:exec) { true }
      base.stub(:refs_for_stage) do
        [
          AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2008"),
          AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2009"),
          AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2010")
        ]
      end
      base.repo.should_receive(:exec).with("update-ref -d refs/tags/ci/2008")
      base.repo.should_receive(:exec).with("update-ref -d refs/tags/ci/2009")
      base.repo.should_not_receive(:exec).with("update-ref -d refs/tags/ci/2010")
      base.delete_locally
    end
  end

  describe "#delete_on_remote" do
    it "blows up if you don't enter a stage" do
      base = AutoTagger::Base.new({})
      proc do
        base.delete_on_remote
      end.should raise_error(AutoTagger::Base::StageCannotBeBlankError)
    end

    it "does not push if there are no tags" do
      base = AutoTagger::Base.new :stage => "ci"
      base.stub(:refs_for_stage).with("ci") {[]}
      base.repo.should_not_receive(:exec)
      base.delete_on_remote
    end

    it "executes the remote delete commands in a batch" do
      base = AutoTagger::Base.new :stage => "ci"
      base.repo.stub(:exec) { true }
      base.stub(:refs_for_stage).with("ci") do
        [
          AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2008"),
          AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2009"),
          AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2010")
        ]
      end
      base.repo.should_receive(:exec).with("push origin :refs/tags/ci/2008 :refs/tags/ci/2009")
      base.delete_on_remote
    end
  end

  describe "#cleanup" do
    it "blows up if you don't enter a stage" do
      base = AutoTagger::Base.new({})
      proc do
        base.cleanup
      end.should raise_error(AutoTagger::Base::StageCannotBeBlankError)
    end

    it "executes delete locally" do
      base = AutoTagger::Base.new :stage => "ci"
      base.repo.stub(:exec) { true }
      base.stub(:refs_for_stage).with("ci") { [AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2008")] }
      base.should_receive(:delete_local_refs)
      base.cleanup
    end

    it "executes delete on remote if push refs is true" do
      base = AutoTagger::Base.new :stage => "ci"
      base.repo.stub(:exec) { true }
      base.stub(:refs_for_stage).with("ci") { [AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2008")] }
      base.should_receive(:delete_remote_refs)
      base.cleanup
    end

    it "does not execute delete on remote if push refs is false" do
      base = AutoTagger::Base.new :stage => "ci", :offline => true
      base.repo.stub(:exec) { true }
      base.stub(:refs_for_stage).with("ci") { [AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2008")] }
      base.should_not_receive(:delete_remote_refs)
      base.cleanup
    end
  end

  describe ".items_to_remove" do
    it "returns the items that can be removed from an array, based on the keep value passed in" do
      AutoTagger::Base.items_to_remove(["2008"], 0).should == ["2008"]
      AutoTagger::Base.items_to_remove(["2008"], 1).should == []
      AutoTagger::Base.items_to_remove(["2008", "2009"], 0).should == ["2008", "2009"]
      AutoTagger::Base.items_to_remove(["2008", "2009"], 1).should == ["2008"]
      AutoTagger::Base.items_to_remove(["2008", "2009"], 2).should == []
      AutoTagger::Base.items_to_remove(["2008", "2009"], 3).should == []
      AutoTagger::Base.items_to_remove(["2008", "2009", "2010"], 0).should == ["2008", "2009", "2010"]
      AutoTagger::Base.items_to_remove(["2008", "2009", "2010"], 1).should == ["2008", "2009"]
      AutoTagger::Base.items_to_remove(["2008", "2009", "2010"], 2).should == ["2008"]
      AutoTagger::Base.items_to_remove(["2008", "2009", "2010"], 3).should == []
    end
  end

  describe "#refs_for_stage" do
    it "returns refs that match the given stage" do
      base = AutoTagger::Base.new :stage => "ci"
      base.repo.stub(:exec) { true }
      refs = [
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/auto_tags/ci/2008"),
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2009"),
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/2009"),
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags-ci/2009"),
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/heads/master")
      ]
      base.repo.stub(:refs) { mock("RefSet", :all => refs) }
      base.refs_for_stage("ci").should == [
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2009")
      ]
    end
  end

  describe "#list" do
    it "return a list of refs for the given stage" do
      base = AutoTagger::Base.new :stage => "ci"
      base.should_receive(:fetch)
      base.should_receive(:refs_for_stage).with("ci")
      base.list
    end
  end

  describe "#release_tag_entries" do
    it "lists the last ref from each stage" do
      base = AutoTagger::Base.new :stage => "ci", :stages => ["ci", "demo", "production"]
      base.repo.stub(:exec) { true }
      refs = [
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2008"),
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2009"),
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/demo/2008"),
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/demo/2009"),
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/production/2008"),
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/production/2009")
      ]
      base.repo.stub(:refs) { mock("RefSet", :all => refs) }
      base.release_tag_entries.should == [
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/ci/2009"),
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/demo/2009"),
        AutoTagger::Git::Ref.new(base.repo, "abc123", "refs/tags/production/2009")
      ]
    end
  end


end

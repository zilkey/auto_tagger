require 'spec_helper'

describe AutoTagger::Git::Repo do

  before do
    File.stub(:exists?).and_return(true)
    @commander = mock(AutoTagger::Commander)
  end

  describe "#path" do
    it "raises an error if the path is blank" do
      proc do
        AutoTagger::Git::Repo.new(" ").path
      end.should raise_error(AutoTagger::Git::Repo::NoPathProvidedError)

      proc do
        AutoTagger::Git::Repo.new(nil).path
      end.should raise_error(AutoTagger::Git::Repo::NoPathProvidedError)
    end

    it "raises and error if the path does not exist" do
      File.should_receive(:exists?).with("/foo").and_return(false)
      proc do
        AutoTagger::Git::Repo.new("/foo").path
      end.should raise_error(AutoTagger::Git::Repo::NoSuchPathError)
    end

    it "raises and error if the path does not have a .git directory" do
      File.should_receive(:exists?).with("/foo").and_return(true)
      File.should_receive(:exists?).with("/foo/.git").and_return(false)
      proc do
        AutoTagger::Git::Repo.new("/foo").path
      end.should raise_error(AutoTagger::Git::Repo::InvalidGitRepositoryError)
    end

    it "returns the path if it's a git directory" do
      File.should_receive(:exists?).with("/foo").and_return(true)
      File.should_receive(:exists?).with("/foo/.git").and_return(true)
      AutoTagger::Git::Repo.new("/foo").path.should == "/foo"
    end
  end

  describe "#refs" do
    it "returns a new refset" do
      AutoTagger::Git::Repo.new("/foo").refs.should be_kind_of(AutoTagger::Git::RefSet)
    end
  end

  describe "#==" do
    it "returns true if the path matches" do
      AutoTagger::Git::Repo.new("/foo").should == AutoTagger::Git::Repo.new("/foo")
    end

    it "returns false if the path does not match" do
      AutoTagger::Git::Repo.new("/foo").should_not == AutoTagger::Git::Repo.new("/bar")
    end
  end

  describe "#latest_commit_sha" do
    it "returns the latest sha from HEAD" do
      repo = AutoTagger::Git::Repo.new("/foo")
      repo.should_receive(:read).with("rev-parse HEAD").and_return(" abc123 ")
      repo.latest_commit_sha.should == "abc123"
    end
  end

  describe "#read" do
    it "formats the command and sends it to the system" do
      repo = AutoTagger::Git::Repo.new("/foo")
      repo.stub(:commander).and_return(@commander)
      @commander.should_receive(:read).with("git rev-parse HEAD").and_return("lkj")
      repo.read("rev-parse HEAD").should == "lkj"
    end

    it "respects the passed in executable" do
      repo = AutoTagger::Git::Repo.new("/foo", :executable => "/usr/bin/git")
      repo.stub(:commander).and_return(@commander)
      @commander.should_receive(:read).with("/usr/bin/git rev-parse HEAD").and_return("lkj")
      repo.read("rev-parse HEAD").should == "lkj"
    end
  end

  describe "#exec" do
    it "sends the exec command to the commander" do
      repo = AutoTagger::Git::Repo.new("/foo")
      repo.stub(:commander).and_return(@commander)
      @commander.should_receive(:execute).with("git push origin master").and_return(true)
      repo.exec("push origin master")
    end

    it "raises an error if the command returns false" do
      repo = AutoTagger::Git::Repo.new("/foo")
      repo.stub(:commander).and_return(@commander)
      @commander.should_receive(:execute).with("git push origin master").and_return(false)
      proc do
        repo.exec("push origin master")
      end.should raise_error(AutoTagger::Git::Repo::GitCommandFailedError)
    end

    it "sends the print command to the commander if execute_commands is false" do
      repo = AutoTagger::Git::Repo.new("/foo", :execute_commands => false)
      repo.stub(:commander).and_return(@commander)
      @commander.should_receive(:print).with("git push origin master")
      repo.exec("push origin master")
    end
  end

end

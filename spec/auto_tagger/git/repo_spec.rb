require 'spec_helper'

describe AutoTagger::Git::Repo do
  describe ".new" do
    it "sets the repo" do
      mock(File).exists?(anything).twice { true }
      configuration = AutoTagger::Configuration.new({:path => "/foo"})
      repo = AutoTagger::Git::Repo.new(configuration)
      repo.path.should == "/foo"
    end

    it "raises an error with a file that doesn't exist" do
      mock(File).exists?("/foo") { false }
      proc do
        configuration = AutoTagger::Configuration.new({:path => "/foo"})
        AutoTagger::Git::Repo.new(configuration)
      end.should raise_error(AutoTagger::NoSuchPathError)
    end

    it "raises an error with a non-git repository" do
      mock(File).exists?("/foo") { true }
      mock(File).exists?("/foo/.git") { false }
      proc do
        configuration = AutoTagger::Configuration.new({:path => "/foo"})
        AutoTagger::Git::Repo.new(configuration)
      end.should raise_error(AutoTagger::InvalidGitRepositoryError)
    end
  end

  describe "#==" do
    it "compares paths" do
      configuration = AutoTagger::Configuration.new({:path => "/foo"})
      other_configuration = AutoTagger::Configuration.new({:path => "/bar"})
      mock(File).exists?(anything).times(any_times) { true }
      AutoTagger::Git::Repo.new(configuration).should_not == "/foo"
      AutoTagger::Git::Repo.new(configuration).should_not == AutoTagger::Git::Repo.new(other_configuration)
      AutoTagger::Git::Repo.new(configuration).should == AutoTagger::Git::Repo.new(configuration)
    end
  end

  describe "#run" do
    it "sends the correct command" do
      configuration = AutoTagger::Configuration.new({:path => "/foo"})
      mock(File).exists?(anything).twice { true }
      mock(AutoTagger::Commander).execute("/foo", "bar")
      AutoTagger::Git::Repo.new(configuration).run("bar")
    end
  end

  describe "run!" do
    it "sends the correct command" do
      configuration = AutoTagger::Configuration.new({:path => "/foo"})
      mock(File).exists?(anything).twice { true }
      mock(AutoTagger::Commander).execute?("/foo", "bar") { true }
      AutoTagger::Git::Repo.new(configuration).run!("bar")
    end

    it "raises an exception if it the command returns false" do
      configuration = AutoTagger::Configuration.new({:path => "/foo"})
      mock(File).exists?(anything).twice { true }
      mock(AutoTagger::Commander).execute?("/foo", "bar") { false }
      proc do
        AutoTagger::Git::Repo.new(configuration).run!("bar")
      end.should raise_error(AutoTagger::GitCommandFailedError)
    end
  end

end

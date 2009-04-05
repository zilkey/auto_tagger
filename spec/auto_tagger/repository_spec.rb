require File.dirname(__FILE__) + '/../spec_helper'

describe AutoTagger::Repository do
  describe ".new" do
    it "sets the repo" do
      mock(File).exists?(anything).twice { true }
      repo = AutoTagger::Repository.new("/foo")
      repo.path.should == "/foo"
    end

    it "raises an error when the path is blank" do
      proc do
        AutoTagger::Repository.new(" ")
      end.should raise_error(AutoTagger::NoPathProvidedError)
    end

    it "raises an error when the path is nil" do
      proc do
        AutoTagger::Repository.new(nil)
      end.should raise_error(AutoTagger::NoPathProvidedError)
    end

    it "raises an error with a file that doesn't exist" do
      mock(File).exists?("/foo") { false }
      proc do
        AutoTagger::Repository.new("/foo")
      end.should raise_error(AutoTagger::NoSuchPathError)
    end

    it "raises an error with a non-git repository" do
      mock(File).exists?("/foo") { true }
      mock(File).exists?("/foo/.git") { false }
      proc do
        AutoTagger::Repository.new("/foo")
      end.should raise_error(AutoTagger::InvalidGitRepositoryError)
    end
  end

  describe "#==" do
    it "compares paths" do
      mock(File).exists?(anything).times(any_times) { true }
      AutoTagger::Repository.new("/foo").should_not == "/foo"
      AutoTagger::Repository.new("/foo").should_not == AutoTagger::Repository.new("/bar")
      AutoTagger::Repository.new("/foo").should == AutoTagger::Repository.new("/foo")
    end
  end

  describe "#run" do
    it "sends the correct command" do
      mock(File).exists?(anything).twice { true }
      mock(AutoTagger::Commander).execute("/foo", "bar")
      AutoTagger::Repository.new("/foo").run("bar")
    end
  end

  describe "run!" do
    it "sends the correct command" do
      mock(File).exists?(anything).twice { true }
      mock(AutoTagger::Commander).execute?("/foo", "bar") { true }
      AutoTagger::Repository.new("/foo").run!("bar")
    end

    it "raises an exception if it the command returns false" do
      mock(File).exists?(anything).twice { true }
      mock(AutoTagger::Commander).execute?("/foo", "bar") { false }
      proc do
        AutoTagger::Repository.new("/foo").run!("bar")
      end.should raise_error(AutoTagger::GitCommandFailedError)
    end
  end

end

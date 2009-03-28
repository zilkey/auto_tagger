require File.dirname(__FILE__) + '/../spec_helper'

describe Repository do
  describe ".new" do
    it "sets the repo" do
      mock(File).exists?(anything).twice { true }
      repo = Repository.new("/foo")
      repo.path.should == "/foo"
    end

    it "raises an error when the path is blank" do
      proc do
        Repository.new(" ")
      end.should raise_error(Repository::NoPathProvidedError)
    end

    it "raises an error when the path is nil" do
      proc do
        Repository.new(nil)
      end.should raise_error(Repository::NoPathProvidedError)
    end

    it "raises an error with a file that doesn't exist" do
      mock(File).exists?("/foo") { false }
      proc do
        Repository.new("/foo")
      end.should raise_error(Repository::NoSuchPathError)
    end

    it "raises an error with a non-git repository" do
      mock(File).exists?("/foo") { true }
      mock(File).exists?("/foo/.git") { false }
      proc do
        Repository.new("/foo")
      end.should raise_error(Repository::InvalidGitRepositoryError)
    end
  end

  describe "#==" do
    it "compares paths" do
      mock(File).exists?(anything).times(any_times) { true }
      Repository.new("/foo").should_not == "/foo"
      Repository.new("/foo").should_not == Repository.new("/bar")
      Repository.new("/foo").should == Repository.new("/foo")
    end
  end

  describe "#run" do
    it "sends the correct command" do
      mock(File).exists?(anything).twice { true }
      mock(Commander).execute("/foo", "bar")
      Repository.new("/foo").run("bar")
    end
  end

  describe "run!" do
    it "sends the correct command" do
      mock(File).exists?(anything).twice { true }
      mock(Commander).execute!("/foo", "bar") { true }
      Repository.new("/foo").run!("bar")
    end

    it "raises an exception if it the command returns false" do
      mock(File).exists?(anything).twice { true }
      mock(Commander).execute!("/foo", "bar") { false }
      proc do
        Repository.new("/foo").run!("bar")
      end.should raise_error(Repository::GitCommandFailedError)
    end
  end

end

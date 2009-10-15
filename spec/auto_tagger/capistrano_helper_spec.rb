require File.dirname(__FILE__) + '/../spec_helper'

describe CapistranoHelper do

  describe ".new" do
    it "blows up if there are no stages" do
      proc do
        CapistranoHelper.new({})
      end.should raise_error(StageManager::NoStagesSpecifiedError)
    end
  end

  describe "#variables" do
    it "returns all variables" do
      CapistranoHelper.new({:autotagger_stages => [:bar]}).variables.should == {:autotagger_stages => [:bar]}
    end
  end

  describe "#working_directory" do
    it "returns the hashes' working directory value" do
      CapistranoHelper.new({:autotagger_stages => [:bar], :working_directory => "/foo"}).working_directory.should == "/foo"
    end

    it "defaults to Dir.pwd if it's not set, or it's nil" do
      mock(Dir).pwd { "/bar" }
      CapistranoHelper.new({:autotagger_stages => [:bar]}).working_directory.should == "/bar"
    end
  end

  describe "#stage" do
    it "returns the hashes' current stage value" do
      CapistranoHelper.new({:autotagger_stages => [:bar], :stage => :bar}).stage.should == :bar
      CapistranoHelper.new({:autotagger_stages => [:bar]}).stage.should be_nil
    end
  end

  describe "#release_tag_entries" do
    it "returns a column-justifed version of all the commits" do
      mock(Commander).execute("/foo", "git tag").times(any_times) { "ci/01\nstaging/01\nproduction/01" }
      mock(Commander).execute("/foo", "git --no-pager log ci/01 --pretty=oneline -1") { "guid1" }
      mock(Commander).execute("/foo", "git --no-pager log staging/01 --pretty=oneline -1") { "guid2" }
      mock(Commander).execute("/foo", "git --no-pager log production/01 --pretty=oneline -1") { "guid3" }
      mock(Commander).execute!("/foo", "git fetch origin --tags").times(any_times) { true }
      mock(File).exists?(anything).times(any_times) {true}

      variables = {
        :working_directory => "/foo",
        :autotagger_stages => [:ci, :staging, :production]
      }
      histories = CapistranoHelper.new(variables).release_tag_entries
      histories.length.should == 3
      histories[0].should include("ci/01", "guid1")
      histories[1].should include("staging/01", "guid2")
      histories[2].should include("production/01", "guid3")
    end

    it "ignores tags delimited with '_'" do
      mock(Commander).execute("/foo", "git tag").times(any_times) { "ci/01\nci_02" }
      mock(Commander).execute("/foo", "git --no-pager log ci/01 --pretty=oneline -1") { "guid1" }
      mock(Commander).execute!("/foo", "git fetch origin --tags").times(any_times) { true }
      mock(File).exists?(anything).times(any_times) {true}

      variables = {
        :working_directory => "/foo",
        :autotagger_stages => [:ci]
      }
      histories = CapistranoHelper.new(variables).release_tag_entries
      histories.length.should == 1
      histories[0].should include("ci/01", "guid1")
    end
  end

  describe "#branch" do
    describe "with :head and :branch specified" do
      it "returns master" do
        variables = {
          :autotagger_stages => [:bar],
          :head => nil,
          :branch => "foo"
        }
        CapistranoHelper.new(variables).branch.should == "foo"
      end
    end

    describe "with :head specified, but no branch specified" do
      it "returns master" do
        variables = {
          :autotagger_stages => [:bar],
          :head => nil
        }
        CapistranoHelper.new(variables).branch.should == nil
      end
    end

    describe "with :branch specified" do
      it "returns the value of branch" do
        variables = {
          :autotagger_stages => [:bar],
          :branch => "foo"
        }
        CapistranoHelper.new(variables).branch.should == "foo"
      end
    end

    describe "with a previous stage with a tag" do
      it "returns the latest tag for the previous stage" do
        variables = {
          :autotagger_stages => [:foo, :bar],
          :stage => :bar,
          :branch => "master",
          :working_directory => "/foo"
        }
        tagger = Object.new
        mock(tagger).latest_tag { "foo_01" }
        mock(AutoTagger).new("foo", "/foo") { tagger }
        CapistranoHelper.new(variables).branch.should == "foo_01"
      end
    end

    describe "with no branch and a previous stage with no tag" do
      it "returns nil" do
        variables = {
          :autotagger_stages => [:foo, :bar],
          :stage => :bar,
          :working_directory => "/foo"
        }
        tagger = Object.new
        mock(tagger).latest_tag { nil }
        mock(AutoTagger).new("foo", "/foo") { tagger }
        CapistranoHelper.new(variables).branch.should == nil
      end
    end

    describe "with no branch and previous stage" do
      it "returns nil" do
        variables = {
          :autotagger_stages => [:bar],
          :stage => :bar
        }
        CapistranoHelper.new(variables).previous_stage.should be_nil
        CapistranoHelper.new(variables).branch.should == nil
      end
    end
  end

end

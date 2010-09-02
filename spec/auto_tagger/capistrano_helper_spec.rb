require 'spec_helper'

describe AutoTagger::CapistranoHelper do

  describe "#stage_manager" do
    it "blows up if there are no stages" do
      proc do
        AutoTagger::CapistranoHelper.new({}).stage_manager
      end.should raise_error(AutoTagger::StageManager::NoStagesSpecifiedError)
    end
  end

  describe "#variables" do
    it "returns all variables" do
      AutoTagger::CapistranoHelper.new({:auto_tagger_stages => [:bar]}).variables.should == {:auto_tagger_stages => [:bar]}
    end
  end

  describe "#working_directory" do
    it "returns the hashes' working directory value", :deprecated => true do
      mock(AutoTagger::Deprecator).warn(":working_directory is deprecated.  Please use :auto_tagger_working_directory or see the readme for the new api.")
      AutoTagger::CapistranoHelper.new({:auto_tagger_stages => [:bar], :working_directory => "/foo"})
    end

    it "returns the hashes' auto_tagger_working_directory value" do
      AutoTagger::CapistranoHelper.new({:auto_tagger_working_directory => "/foo"}).configuration.working_directory.should == "/foo"
    end

    it "defaults to Dir.pwd if it's not set, or it's nil", :deprecated => true do
      mock(Dir).pwd { "/bar" }
      AutoTagger::CapistranoHelper.new({:auto_tagger_stages => [:bar]}).configuration.working_directory.should == "/bar"
    end
  end

  describe "#stage" do
    it "returns the hashes' current stage value" do
      AutoTagger::CapistranoHelper.new({:auto_tagger_stages => [:bar], :stage => :bar}).configuration.stage.should == :bar
      AutoTagger::CapistranoHelper.new({:auto_tagger_stages => [:bar]}).configuration.stage.should be_nil
    end
  end

  describe "#release_tag_entries" do
    it "returns a column-justifed version of all the commits" do
      mock(AutoTagger::Commander).execute("/foo", "git tag").times(any_times) { "ci/01\nstaging/01\nproduction/01" }
      mock(AutoTagger::Commander).execute("/foo", "git --no-pager log ci/01 --pretty=oneline -1") { "guid1" }
      mock(AutoTagger::Commander).execute("/foo", "git --no-pager log staging/01 --pretty=oneline -1") { "guid2" }
      mock(AutoTagger::Commander).execute("/foo", "git --no-pager log production/01 --pretty=oneline -1") { "guid3" }
      mock(AutoTagger::Commander).execute?("/foo", "git fetch origin --tags").times(any_times) { true }
      mock(File).exists?(anything).times(any_times) { true }

      variables = {
        :auto_tagger_working_directory => "/foo",
        :auto_tagger_stages => [:ci, :staging, :production]
      }
      histories = AutoTagger::CapistranoHelper.new(variables).release_tag_entries
      histories.length.should == 3
      histories[0].should include("ci/01", "guid1")
      histories[1].should include("staging/01", "guid2")
      histories[2].should include("production/01", "guid3")
    end

    it "ignores tags delimited with '_'" do
      mock(AutoTagger::Commander).execute("/foo", "git tag").times(any_times) { "ci/01\nci_02" }
      mock(AutoTagger::Commander).execute("/foo", "git --no-pager log ci/01 --pretty=oneline -1") { "guid1" }
      mock(AutoTagger::Commander).execute?("/foo", "git fetch origin --tags").times(any_times) { true }
      mock(File).exists?(anything).times(any_times) { true }

      variables = {
        :auto_tagger_working_directory => "/foo",
        :auto_tagger_stages => [:ci]
      }
      histories = AutoTagger::CapistranoHelper.new(variables).release_tag_entries
      histories.length.should == 1
      histories[0].should include("ci/01", "guid1")
    end
  end

  describe "#branch" do
    describe "with :head and :branch specified" do
      it "returns master" do
        variables = {
          :auto_tagger_stages => [:bar],
          :head => nil,
          :branch => "foo"
        }
        AutoTagger::CapistranoHelper.new(variables).branch.should == "foo"
      end
    end

    describe "with :head specified, but no branch specified" do
      it "returns master" do
        variables = {
          :auto_tagger_stages => [:bar],
          :head => nil
        }
        AutoTagger::CapistranoHelper.new(variables).branch.should == nil
      end
    end

    describe "with :branch specified" do
      it "returns the value of branch" do
        variables = {
          :auto_tagger_stages => [:bar],
          :branch => "foo"
        }
        AutoTagger::CapistranoHelper.new(variables).branch.should == "foo"
      end
    end

    describe "with a previous stage with a tag" do
      it "returns the latest tag for the previous stage" do
        variables = {
          :auto_tagger_stages => [:foo, :bar],
          :stage => :bar,
          :branch => "master",
          :auto_tagger_working_directory => "/foo"
        }
        tagger = Object.new
        mock(tagger).latest_ref { "foo_01" }
        mock(AutoTagger::Configuration).new(:stage => "foo", :path => "/foo")
        mock(AutoTagger::Base).new(anything) { tagger }
        AutoTagger::CapistranoHelper.new(variables).branch.should == "foo_01"
      end
    end

    describe "with no branch and a previous stage with no tag" do
      it "returns nil" do
        variables = {
          :auto_tagger_stages => [:foo, :bar],
          :stage => :bar,
          :auto_tagger_working_directory => "/foo"
        }
        tagger = Object.new
        mock(tagger).latest_ref { nil }
        mock(AutoTagger::Configuration).new(:stage => "foo", :path => "/foo")
        mock(AutoTagger::Base).new(anything) { tagger }
        AutoTagger::CapistranoHelper.new(variables).branch.should == nil
      end
    end

    describe "with no branch and previous stage" do
      it "returns nil" do
        variables = {
          :auto_tagger_stages => [:bar],
          :stage => :bar
        }
        AutoTagger::CapistranoHelper.new(variables).previous_stage.should be_nil
        AutoTagger::CapistranoHelper.new(variables).branch.should == nil
      end
    end
  end

end

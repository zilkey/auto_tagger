require 'spec_helper'
require 'ostruct'

describe AutoTagger::Base do
  before(:each) do
    stub(Dir).pwd { File.join(File.dirname(__FILE__), '..', '..') }
    @configuration = OpenStruct.new
  end

  describe "#create_ref" do
    it "blows up if you don't pass a stage" do
      proc do
        @configuration.stage = nil
        AutoTagger::Base.new(@configuration).create_ref
      end.should raise_error(AutoTagger::StageCannotBeBlankError)
    end

    it "generates the correct commands" do
      time = Time.local(2001,1,1)
      mock(Time).now.once {time}
      timestamp = time.utc.strftime('%Y%m%d%H%M%S')
      mock(File).exists?(anything).twice { true }

      mock(AutoTagger::Commander).execute?("/foo", "git fetch origin --tags") {true}
      mock(AutoTagger::Commander).execute?("/foo", "git tag ci/#{timestamp}") {true}
      mock(AutoTagger::Commander).execute?("/foo", "git push origin --tags")  {true}

      configuration = AutoTagger::Configuration.new(:stage => "ci", :path => "/foo")
      AutoTagger::Base.new(configuration).create_ref
    end

    it "allows you to base it off an existing tag or commit" do
      time = Time.local(2001,1,1)
      mock(Time).now.once {time}
      timestamp = time.utc.strftime('%Y%m%d%H%M%S')
      mock(File).exists?(anything).twice { true }

      mock(AutoTagger::Commander).execute?("/foo", "git fetch origin --tags") {true}
      mock(AutoTagger::Commander).execute?("/foo", "git tag ci/#{timestamp} guid") {true}
      mock(AutoTagger::Commander).execute?("/foo", "git push origin --tags")  {true}

      configuration = AutoTagger::Configuration.new(:stage => "ci", :path => "/foo")
      AutoTagger::Base.new(configuration).create_ref("guid")
    end

    it "returns the tag that was created" do
      time = Time.local(2001,1,1)
      mock(Time).now.once {time}
      timestamp = time.utc.strftime('%Y%m%d%H%M%S')
      mock(File).exists?(anything).twice { true }
      mock(AutoTagger::Commander).execute?(anything, anything).times(any_times) {true}

      configuration = AutoTagger::Configuration.new(:stage => "ci", :path => "/foo")
      AutoTagger::Base.new(configuration).create_ref.should == "ci/#{timestamp}"
    end
  end

  describe "#latest_ref" do
    it "should raise a stage cannot be blank error if stage is blank" do
      proc do
        configuration = AutoTagger::Configuration.new(:stage => nil)
        AutoTagger::Base.new(configuration).latest_ref
      end.should raise_error(AutoTagger::StageCannotBeBlankError)
    end

    it "generates the correct commands" do
      mock(File).exists?(anything).twice { true }
      mock(AutoTagger::Commander).execute?("/foo", "git fetch origin --tags") {true}
      mock(AutoTagger::Commander).execute("/foo", "git tag") { "ci_01" }

      configuration = AutoTagger::Configuration.new(:stage => "ci", :path => "/foo")
      AutoTagger::Base.new(configuration).latest_ref
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

end

require 'spec_helper'
require 'ostruct'

describe AutoTagger::Runner do
  before(:each) do
    stub(Dir).pwd { File.join(File.dirname(__FILE__), '..', '..') }
    @configuration = OpenStruct.new
  end

  describe "#create_ref" do
    it "blows up if you don't pass a stage" do
      proc do
        @configuration.stage = nil
        AutoTagger::Runner.new(@configuration).create_ref
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
      AutoTagger::Runner.new(configuration).create_ref
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
      AutoTagger::Runner.new(configuration).create_ref("guid")
    end

    it "returns the tag that was created" do
      time = Time.local(2001,1,1)
      mock(Time).now.once {time}
      timestamp = time.utc.strftime('%Y%m%d%H%M%S')
      mock(File).exists?(anything).twice { true }
      mock(AutoTagger::Commander).execute?(anything, anything).times(any_times) {true}

      configuration = AutoTagger::Configuration.new(:stage => "ci", :path => "/foo")
      AutoTagger::Runner.new(configuration).create_ref.should == "ci/#{timestamp}"
    end
  end

  describe "#latest_ref" do
    it "should raise a stage cannot be blank error if stage is blank" do
      proc do
        configuration = AutoTagger::Configuration.new(:stage => nil)
        AutoTagger::Runner.new(configuration).latest_ref
      end.should raise_error(AutoTagger::StageCannotBeBlankError)
    end

    it "generates the correct commands" do
      mock(File).exists?(anything).twice { true }
      mock(AutoTagger::Commander).execute?("/foo", "git fetch origin --tags") {true}
      mock(AutoTagger::Commander).execute("/foo", "git tag") { "ci_01" }

      configuration = AutoTagger::Configuration.new(:stage => "ci", :path => "/foo")
      AutoTagger::Runner.new(configuration).latest_ref
    end
  end

end

require File.dirname(__FILE__) + '/../spec_helper'

describe AutoTagger do
  before(:each) do
    stub(Dir).pwd { File.join(File.dirname(__FILE__), '..', '..') }
  end

  describe ".new" do
    it "blows up if you don't pass an stage" do
      proc do
        AutoTagger.new(nil)
      end.should raise_error(AutoTagger::EnvironmentCannotBeBlankError)
    end
    
    it "sets the stage when it's passed" do
      AutoTagger.new("ci").stage.should == "ci"
    end

    it "sets the path to Dir.pwd when nil" do
      mock(Dir).pwd { "/foo" }
      mock(Repository).new("/foo")
      AutoTagger.new("ci")
    end

    it "expands the path when the path is passed" do
      mock(Repository).new(File.expand_path("."))
      AutoTagger.new("ci", ".")
    end

    it "exposes the working directory" do
      mock(Repository).new(File.expand_path("."))
      AutoTagger.new("ci", ".").working_directory.should == File.expand_path(".")
    end
  end

  describe "#create_tag" do
    it "generates the correct commands" do
      time = Time.local(2001,1,1)
      mock(Time).now.once {time}
      timestamp = time.utc.strftime('%Y%m%d%H%M%S')
      mock(File).exists?(anything).twice { true }

      mock(Commander).execute!("/foo", "git fetch origin --tags") {true}
      mock(Commander).execute!("/foo", "git tag ci/#{timestamp}") {true}
      mock(Commander).execute!("/foo", "git push origin --tags")  {true}
      
      AutoTagger.new("ci", "/foo").create_tag
    end

    it "allows you to base it off an existing tag or commit" do
      time = Time.local(2001,1,1)
      mock(Time).now.once {time}
      timestamp = time.utc.strftime('%Y%m%d%H%M%S')
      mock(File).exists?(anything).twice { true }

      mock(Commander).execute!("/foo", "git fetch origin --tags") {true}
      mock(Commander).execute!("/foo", "git tag ci/#{timestamp} guid") {true}
      mock(Commander).execute!("/foo", "git push origin --tags")  {true}
      
      AutoTagger.new("ci", "/foo").create_tag("guid")
    end
    
    it "returns the tag that was created" do
      time = Time.local(2001,1,1)
      mock(Time).now.once {time}
      timestamp = time.utc.strftime('%Y%m%d%H%M%S')
      mock(File).exists?(anything).twice { true }
      mock(Commander).execute!(anything, anything).times(any_times) {true}
      
      AutoTagger.new("ci", "/foo").create_tag.should == "ci/#{timestamp}"
    end
  end

  describe "#latest_tag" do
    it "generates the correct commands" do
      mock(File).exists?(anything).twice { true }

      mock(Commander).execute!("/foo", "git fetch origin --tags") {true}
      mock(Commander).execute("/foo", "git tag") { "ci_01" }
      
      AutoTagger.new("ci", "/foo").latest_tag
    end
  end
  
end

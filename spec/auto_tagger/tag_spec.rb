require File.dirname(__FILE__) + '/../spec_helper'

describe Tag do
  
  before(:each) do
    @repository = Object.new
  end

  describe ".new" do
    it "sets the repository" do
      Tag.new(@repository).repository.should == @repository
    end
  end
  
  describe "#find_all" do
    it "returns an array of tags" do
      mock(@repository).run("git tag") { "ci_01\nci_02" }
      Tag.new(@repository).find_all.should == ["ci_01", "ci_02"]
    end

    it "returns an empty array if there are none" do
      mock(@repository).run("git tag") { "" }
      Tag.new(@repository).find_all.should be_empty
    end
  end
  
  describe "#latest_from" do
    before do
      @tag = Tag.new(@repository)
      mock(@tag).find_all { ["ci/01", "ci/02"] }
    end

    it "returns the latest tag that starts with the specified stage" do
      @tag.latest_from(:ci).should == "ci/02"
    end

    it "returns nil if none match" do
      @tag.latest_from(:staging).should be_nil
    end
  end

  describe "#fetch_tags" do
    it "sends the correct command" do
      mock(@repository).run!("git fetch origin --tags")
      Tag.new(@repository).fetch
    end
  end

  describe "#push" do
    it "sends the correct command" do
      mock(@repository).run!("git push origin --tags")
      Tag.new(@repository).push
    end
  end

  describe "#create" do
    it "creates the right command and returns the name" do
      time = Time.local(2001,1,1)
      mock(Time).now.once {time}
      tag_name = "ci/#{time.utc.strftime('%Y%m%d%H%M%S')}"
      mock(@repository).run!("git tag #{tag_name}")
      Tag.new(@repository).create("ci").should == tag_name
    end
  end    
  
end

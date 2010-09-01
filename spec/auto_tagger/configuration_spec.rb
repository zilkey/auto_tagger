require 'spec_helper'

describe AutoTagger::Configuration do

  describe "#task" do
    it "returns :help when :show_help is true" do
      config = AutoTagger::Configuration.new :show_help => true, :show_version => false
      config.task.should == :help
    end

    it "returns :version when version is true" do
      config = AutoTagger::Configuration.new :show_help => false, :show_version => true
      config.task.should == :version
    end

    it "returns :tagger when :version and :show_help are false" do
      config = AutoTagger::Configuration.new :show_help => false, :show_version => false
      config.task.should == :tagger
    end
  end

  specify "stage works" do
    config = AutoTagger::Configuration.new :stage => "ci"
    config.stage.should == "ci"
  end

  describe "#push_refs" do
    it "defaults to true" do
      config = AutoTagger::Configuration.new({})
      config.push_refs?.should be_true
    end

    it "respects the passed-in option" do
      config = AutoTagger::Configuration.new :push_refs => false
      config.push_refs?.should be_false
    end
  end

  describe "#fetch_refs" do
    it "defaults to true" do
      config = AutoTagger::Configuration.new({})
      config.fetch_refs?.should be_true
    end

    it "respects the passed-in option" do
      config = AutoTagger::Configuration.new :fetch_refs => false
      config.fetch_refs?.should be_false
    end
  end

  describe "#working_directory" do
    it "returns the current directory when path is nil" do
      dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
      stub(Dir).pwd { dir }
      config = AutoTagger::Configuration.new({})
      config.working_directory.should == dir
    end

    it "expands path when path is set" do
      dir = File.expand_path(".")
      config = AutoTagger::Configuration.new :path => "."
      config.working_directory.should == dir
    end
  end

  describe "#date_format" do
    it "defaults to %Y%m%d%H%M%S" do
      config = AutoTagger::Configuration.new({})
      config.date_format.should == "%Y%m%d%H%M%S"
    end

    it "returns the passed in separator" do
      config = AutoTagger::Configuration.new :date_format => "%Y%m"
      config.date_format.should == "%Y%m"
    end
  end

end

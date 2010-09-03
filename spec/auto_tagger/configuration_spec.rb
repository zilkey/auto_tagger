require 'spec_helper'

describe AutoTagger::Configuration do

  before do
    # make sure that the specs don't pick up this gem's .auto_tagger file
    File.stub(:read) { nil }
  end

  describe "#working_directory" do
    it "returns the current directory when path is nil" do
      dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
      Dir.stub(:pwd) { dir }
      config = AutoTagger::Configuration.new({})
      config.working_directory.should == dir
    end

    it "expands path when path is set" do
      dir = File.expand_path(".")
      config = AutoTagger::Configuration.new :path => "."
      config.working_directory.should == dir
    end
  end

  describe "#opts_file" do
    it "expands the passed in opts file path in reference to the path" do
      config = AutoTagger::Configuration.new :opts_file => "../.foo_tagger", :path => "/foo/bar"
      config.opts_file.should == "/foo/.foo_tagger"
    end

    it "defaults to looking in the working directories .auto_tagger file" do
      config = AutoTagger::Configuration.new :path => "/foo"
      config.opts_file.should == "/foo/.auto_tagger"
    end
  end

  describe "#file_settings" do
    it "return a hash representing the options specified in the opts file" do
      config = AutoTagger::Configuration.new
      config.stub(:opts_file) { "/foo/.auto_tagger" }
      File.should_receive(:exists?) { true }
      File.should_receive(:read).with("/foo/.auto_tagger").and_return("--offline=false\n--verbose=true")
      config.file_settings.should == {:offline => false, :verbose => true}
    end

    it "ignores blank lines and whitespace" do
      config = AutoTagger::Configuration.new
      config.stub(:opts_file) { "/foo/.auto_tagger" }
      File.should_receive(:exists?).with("/foo/.auto_tagger") { true }
      File.should_receive(:read).with("/foo/.auto_tagger").and_return("  --offline=false  \n\n--verbose=true\n")
      config.file_settings.should == {:offline => false, :verbose => true}
    end

    it "returns an empty hash if the file doens't exist" do
      File.stub(:exists?) { false }
      config = AutoTagger::Configuration.new :path => "/foo"
      config.file_settings.should == {}
    end

    # TODO: print warnings instead of blowing up??
    it "doesn't parse options that are not valid for the opts file" do
      File.stub(:exists?) { true }
      File.should_receive(:read).with("/foo/.auto_tagger").and_return("--opts-file=/foo")
      config = AutoTagger::Configuration.new :path => "/foo"
      proc do
        config.file_settings.should == {}
      end.should raise_error(OptionParser::InvalidOption)
    end
  end

  describe "#settings" do
    it "should merge the passed in settings with the file settings" do
      config = AutoTagger::Configuration.new :stage => "demo", :offline => true
      config.stub(:file_settings).and_return({:stage => "ci", :verbose => false})
      config.settings.should == {:stage => "demo", :offline => true, :verbose => false}
    end
  end

  describe "#stages" do
    it "splits on a comma if it's a string, ignoring whitespace" do
      config = AutoTagger::Configuration.new :stages => ",ci,, demo ,  production,"
      config.stages.should == ["ci", "demo", "production"]
    end

    it "returns the passed in stages if it's an array" do
      config = AutoTagger::Configuration.new :stages => ["ci", "demo"]
      config.stages.should == ["ci", "demo"]
    end

    it "removes blank items" do
      config = AutoTagger::Configuration.new :stages => ["ci", ""]
      config.stages.should == ["ci"]
    end
  end

  describe "#stage" do
    it "should use the stage passed in" do
      config = AutoTagger::Configuration.new :stage => "demo"
      config.stage.should == "demo"
    end

    it "defaults to the last stage if stages is passed in" do
      config = AutoTagger::Configuration.new :stages => ["demo", "production"]
      config.stage.should == "production"
    end
  end

  describe "#date_separator" do
    it "returns the passed in option" do
      config = AutoTagger::Configuration.new :date_separator => "-"
      config.date_separator.should == "-"
    end

    it "defaults to an empty string" do
      config = AutoTagger::Configuration.new
      config.date_separator.should == ""
    end
  end

  describe "#dry_run?" do
    it "returns the passed in option" do
      config = AutoTagger::Configuration.new :dry_run => true
      config.dry_run?.should == true

      config = AutoTagger::Configuration.new :dry_run => false
      config.dry_run?.should == false
    end

    it "defaults to false" do
      config = AutoTagger::Configuration.new
      config.dry_run?.should == false
    end
  end

  describe "#verbose?" do
    it "returns the passed in option" do
      config = AutoTagger::Configuration.new :verbose => true
      config.verbose?.should == true

      config = AutoTagger::Configuration.new :verbose => false
      config.verbose?.should == false
    end

    it "defaults to false" do
      config = AutoTagger::Configuration.new
      config.verbose?.should == false
    end
  end

  describe "#offline?" do
    it "returns the passed in option" do
      config = AutoTagger::Configuration.new :offline => true
      config.offline?.should == true

      config = AutoTagger::Configuration.new :offline => false
      config.offline?.should == false
    end

    it "defaults to false" do
      config = AutoTagger::Configuration.new
      config.offline?.should == false
    end
  end

  describe "#push_refs" do
    it "defaults to true" do
      config = AutoTagger::Configuration.new
      config.push_refs?.should == true
    end

    it "respects the passed-in option" do
      config = AutoTagger::Configuration.new :push_refs => true
      config.push_refs?.should == true

      config = AutoTagger::Configuration.new :push_refs => false
      config.push_refs?.should == false
    end

    it "returns false if offline is true" do
      config = AutoTagger::Configuration.new :offline => true, :push_refs => true
      config.push_refs?.should == false
    end
  end

  describe "#fetch_refs" do
    it "defaults to true" do
      config = AutoTagger::Configuration.new
      config.fetch_refs?.should == true
    end

    it "respects the passed-in option" do
      config = AutoTagger::Configuration.new :fetch_refs => true
      config.fetch_refs?.should == true

      config = AutoTagger::Configuration.new :fetch_refs => false
      config.fetch_refs?.should == false
    end

    it "returns false if offline is true" do
      config = AutoTagger::Configuration.new :offline => true, :fetch_refs => true
      config.fetch_refs?.should == false
    end
  end

  describe "#executable" do
    it "returns the passed in executable" do
      config = AutoTagger::Configuration.new :executable => "/usr/bin/git"
      config.executable.should == "/usr/bin/git"
    end

    it "defaults to git" do
      config = AutoTagger::Configuration.new
      config.executable.should == "git"
    end
  end

  describe "#refs_to_keep" do
    it "return the refs to keep" do
      config = AutoTagger::Configuration.new :refs_to_keep => 4
      config.refs_to_keep.should == 4
    end

    it "defaults to 1" do
      config = AutoTagger::Configuration.new
      config.refs_to_keep.should == 1
    end

    it "always returns a FixNum" do
      config = AutoTagger::Configuration.new :refs_to_keep => "4"
      config.refs_to_keep.should == 4
    end
  end

  describe "#remote" do
    it "returns the passed in option" do
      config = AutoTagger::Configuration.new :remote => "myorigin"
      config.remote.should == "myorigin"
    end

    it "defaults to origin" do
      config = AutoTagger::Configuration.new
      config.remote.should == "origin"
    end
  end

  describe "#ref_path" do
    it "returns the passed in option" do
      config = AutoTagger::Configuration.new :ref_path => "auto_tags"
      config.ref_path.should == "auto_tags"
    end

    it "defaults to tags" do
      config = AutoTagger::Configuration.new
      config.ref_path.should == "tags"
    end

    it "raises an error if you pass in heads or remotes" do
      proc do
        config = AutoTagger::Configuration.new :ref_path => "heads"
        config.ref_path.should == "tags"
      end.should raise_error(AutoTagger::Configuration::InvalidRefPath)

      proc do
        config = AutoTagger::Configuration.new :ref_path => "heads"
        config.ref_path.should == "tags"
      end.should raise_error(AutoTagger::Configuration::InvalidRefPath)
    end
  end

end

require 'spec_helper'

describe AutoTagger::CommandLine do

  describe "#execute" do
    it "runs the version command" do
      command_line = AutoTagger::CommandLine.new ["version"]
      command_line.execute.first.should be_true
      command_line.execute.last.should include(AutoTagger.version)
    end

    it "runs the help command" do
      command_line = AutoTagger::CommandLine.new ["help"]
      command_line.execute.last.should include("USAGE")
    end

    it "runs the cleanup command" do
      command_line = AutoTagger::CommandLine.new ["cleanup"]
      tagger = mock(AutoTagger::Base, :cleanup => 7)
      AutoTagger::Base.should_receive(:new).and_return(tagger)
      command_line.execute.last.should include("7")
    end

    it "runs the list command" do
      command_line = AutoTagger::CommandLine.new ["list"]
      tagger = mock(AutoTagger::Base, :list => ["foo", "bar"])
      AutoTagger::Base.should_receive(:new).and_return(tagger)
      command_line.execute.last.should include("foo", "bar")
    end

    it "runs the config command" do
      command_line = AutoTagger::CommandLine.new ["config"]
      config = mock(AutoTagger::Configuration, :settings => {"foo" =>  "bar"})
      AutoTagger::Configuration.should_receive(:new).and_return(config)
      command_line.execute.last.should include("foo", "bar")
    end

    it "runs the create command" do
      command_line = AutoTagger::CommandLine.new ["create"]
      tagger = mock(AutoTagger::Base, :create_ref => mock(AutoTagger::Git::Ref, :name => "refs/tags"))
      AutoTagger::Base.should_receive(:new).and_return(tagger)
      command_line.execute.last.should include("refs/tags")
    end

    it "includes a deprecation command when necessary" do
      command_line = AutoTagger::CommandLine.new ["ci"]
      tagger = mock(AutoTagger::Base, :create_ref => mock(AutoTagger::Git::Ref, :name => "refs/tags"))
      AutoTagger::Base.should_receive(:new).and_return(tagger)
      result = command_line.execute.last
      result.should include("DEPRECATION")
      result.should include("refs/tags")
    end

  end

end
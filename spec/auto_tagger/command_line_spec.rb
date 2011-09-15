require 'spec_helper'

describe AutoTagger::CommandLine do

  describe "#execute" do
    it "runs the version command" do
      command_line = AutoTagger::CommandLine.new ["version"]
      command_line.execute.first.should be_true
      command_line.execute.last.should include(AutoTagger::VERSION)
    end

    it "runs the help command" do
      command_line = AutoTagger::CommandLine.new ["help"]
      command_line.execute.last.should include("USAGE")
    end

    describe "#cleanup" do
      it "runs the cleanup command with a stage" do
        command_line = AutoTagger::CommandLine.new ["cleanup"]
        tagger = mock(AutoTagger::Base, :cleanup => 7)
        AutoTagger::Base.should_receive(:new).and_return(tagger)
        command_line.execute.last.should include("7")
      end

      it "prints a friendly error message when no stage is provided" do
        command_line = AutoTagger::CommandLine.new ["cleanup"]
        AutoTagger::Base.should_receive(:new).and_raise(AutoTagger::Base::StageCannotBeBlankError)
        command_line.execute.last.should include("You must provide a stage")
      end
    end

    describe "#delete_locally" do
      it "runs the delete_locally command" do
        command_line = AutoTagger::CommandLine.new ["delete_locally"]
        tagger = mock(AutoTagger::Base, :delete_locally => 7)
        AutoTagger::Base.should_receive(:new).and_return(tagger)
        command_line.execute.last.should include("7")
      end

      it "prints a friendly error message when no stage is provided" do
        command_line = AutoTagger::CommandLine.new ["delete_locally"]
        AutoTagger::Base.should_receive(:new).and_raise(AutoTagger::Base::StageCannotBeBlankError)
        command_line.execute.last.should include("You must provide a stage")
      end
    end

    describe "#delete_on_remote" do
      it "runs the delete_on_remote command" do
        command_line = AutoTagger::CommandLine.new ["delete_on_remote"]
        tagger = mock(AutoTagger::Base, :delete_on_remote => 7)
        AutoTagger::Base.should_receive(:new).and_return(tagger)
        command_line.execute.last.should include("7")
      end

      it "prints a friendly error message when no stage is provided" do
        command_line = AutoTagger::CommandLine.new ["delete_on_remote"]
        AutoTagger::Base.should_receive(:new).and_raise(AutoTagger::Base::StageCannotBeBlankError)
        command_line.execute.last.should include("You must provide a stage")
      end
    end

    describe "#list" do
      it "runs the list command" do
        command_line = AutoTagger::CommandLine.new ["list"]
        tagger = mock(AutoTagger::Base, :list => ["foo", "bar"])
        AutoTagger::Base.should_receive(:new).and_return(tagger)
        command_line.execute.last.should include("foo", "bar")
      end

      it "prints a friendly error message when no stage is provided" do
        command_line = AutoTagger::CommandLine.new ["list"]
        AutoTagger::Base.should_receive(:new).and_raise(AutoTagger::Base::StageCannotBeBlankError)
        command_line.execute.last.should include("You must provide a stage")
      end
    end

    it "runs the config command" do
      command_line = AutoTagger::CommandLine.new ["config"]
      config = mock(AutoTagger::Configuration, :settings => {"foo" =>  "bar"})
      AutoTagger::Configuration.should_receive(:new).and_return(config)
      command_line.execute.last.should include("foo", "bar")
    end

    describe "#create" do
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

      it "prints a friendly error message when no stage is provided" do
        command_line = AutoTagger::CommandLine.new ["create"]
        AutoTagger::Base.should_receive(:new).and_raise(AutoTagger::Base::StageCannotBeBlankError)
        command_line.execute.last.should include("You must provide a stage")
      end
    end

  end

end

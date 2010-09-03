require 'spec_helper'

describe AutoTagger::Options do

  shared_examples_for "common options" do
    it "understands --date-format" do
      options = AutoTagger::Options.from_command_line ["--date-format=%Y%m%d%H%M%S"]
      options[:date_format].should == "%Y%m%d%H%M%S"
    end

    it "understands --remote" do
      options = AutoTagger::Options.from_command_line ["--remote=origin"]
      options[:remote].should == "origin"
    end

    it "understands --ref-path" do
      options = AutoTagger::Options.from_command_line ["--ref-path=tags"]
      options[:ref_path].should == "tags"
    end

    it "understands --stages" do
      options = AutoTagger::Options.from_command_line ["--stages=foo,bar,baz"]
      options[:stages].should == "foo,bar,baz"
    end

    it "understands --refs-to-keep" do
      options = AutoTagger::Options.from_command_line ["--refs-to-keep=4"]
      options[:refs_to_keep].should == 4
    end

    it "understands --dry-run" do
      options = AutoTagger::Options.from_command_line ["--dry-run"]
      options[:dry_run].should be_true

      options = AutoTagger::Options.from_command_line ["--dry-run=true"]
      options[:dry_run].should be_true

      options = AutoTagger::Options.from_command_line ["--dry-run=false"]
      options[:dry_run].should be_false
    end

    it "understands --fetch-refs" do
      options = AutoTagger::Options.from_command_line ["--fetch-refs=true"]
      options[:fetch_refs].should == true

      options = AutoTagger::Options.from_command_line ["--fetch-refs=false"]
      options[:fetch_refs].should == false
    end

    it "understands --push-refs" do
      options = AutoTagger::Options.from_command_line ["--push-refs=true"]
      options[:push_refs].should == true

      options = AutoTagger::Options.from_command_line ["--push-refs=false"]
      options[:push_refs].should == false
    end

    it "understands --offline" do
      options = AutoTagger::Options.from_command_line ["--offline"]
      options[:offline].should be_nil

      options = AutoTagger::Options.from_command_line ["--offline=true"]
      options[:offline].should be_true
    end
  end

  describe "#from_command_line" do

    it_should_behave_like "common options"

    it "takes the first argument to be the stage" do
      options = AutoTagger::Options.from_command_line ["ci"]
      options[:stage].should == "ci"
    end

    it "takes the second argument to be the path" do
      options = AutoTagger::Options.from_command_line ["ci", "../"]
      options[:path].should == "../"
    end

    it "understands --opts-file" do
      options = AutoTagger::Options.from_command_line ["--opts-file=foo"]
      options[:opts_file].should == "foo"
    end

    it "understands all help options" do
      options = AutoTagger::Options.from_command_line ["ci"]
      options[:show_help].should be_nil

      options = AutoTagger::Options.from_command_line ["help"]
      options[:show_help].should == true

      options = AutoTagger::Options.from_command_line ["-h"]
      options[:show_help].should == true

      options = AutoTagger::Options.from_command_line ["--help"]
      options[:show_help].should == true

      options = AutoTagger::Options.from_command_line ["-?"]
      options[:show_help].should == true

      options = AutoTagger::Options.from_command_line []
      options[:show_help].should == true
    end

    it "understands --version" do
      options = AutoTagger::Options.from_command_line ["ci"]
      options[:show_version].should be_nil

      options = AutoTagger::Options.from_command_line ["version"]
      options[:show_version].should == true

      options = AutoTagger::Options.from_command_line ["--version"]
      options[:show_version].should == true

      options = AutoTagger::Options.from_command_line ["-v"]
      options[:show_version].should == true
    end

    it "chooses the right command" do
      options = AutoTagger::Options.from_command_line ["config"]
      options[:command].should == :config

      options = AutoTagger::Options.from_command_line ["version"]
      options[:command].should == :version

      options = AutoTagger::Options.from_command_line ["help"]
      options[:command].should == :help

      options = AutoTagger::Options.from_command_line [""]
      options[:command].should == :help

      options = AutoTagger::Options.from_command_line ["cleanup"]
      options[:command].should == :cleanup

      options = AutoTagger::Options.from_command_line ["list"]
      options[:command].should == :list

      options = AutoTagger::Options.from_command_line ["create"]
      options[:command].should == :create

      options = AutoTagger::Options.from_command_line ["ci"]
      options[:command].should == :create
    end
  end

  describe "#from_file" do
    it_should_behave_like "common options"
  end

end
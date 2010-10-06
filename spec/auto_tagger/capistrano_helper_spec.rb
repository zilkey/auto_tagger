require 'spec_helper'

describe AutoTagger::CapistranoHelper do

  describe "#ref" do
    it "returns the specified branch when passed the :head variable" do
      helper = AutoTagger::CapistranoHelper.new :branch => "release", :head => nil
      helper.ref.should == "release"
    end

    it "returns the specified tag" do
      helper = AutoTagger::CapistranoHelper.new :tag => "v0.1.7"
      helper.ref.should == "v0.1.7"
    end

    it "returns the specified ref" do
      helper = AutoTagger::CapistranoHelper.new :ref => "refs/auto_tags/ci"
      helper.ref.should == "refs/auto_tags/ci"
    end

    it "returns the sha of the last ref from that stage" do
      helper = AutoTagger::CapistranoHelper.new({})
      ref = mock(AutoTagger::Git::Ref, :sha => "abc123")
      auto_tagger = mock AutoTagger::Base, :last_ref_from_previous_stage => ref
      helper.stub(:auto_tagger) { auto_tagger }
      helper.ref.should == "abc123"
    end

    it "returns the branch when specified" do
      helper = AutoTagger::CapistranoHelper.new :branch => "release"
      helper.ref.should == "release"
    end
  end

  describe "#auto_tagger" do
    it "returns an AutoTagger::Base object with the correct options" do
      helper = AutoTagger::CapistranoHelper.new({})
      helper.stub(:auto_tagger_options).and_return({:foo => "bar"})
      AutoTagger::Base.should_receive(:new).with({:foo => "bar"})
      helper.auto_tagger
    end
  end

  describe "#auto_tagger_options" do
    it "includes :stage from :auto_tagger_stage, :stage" do
      helper = AutoTagger::CapistranoHelper.new :stage => "demo"
      helper.auto_tagger_options[:stage].should == "demo"

      helper = AutoTagger::CapistranoHelper.new :auto_tagger_stage => "demo"
      helper.auto_tagger_options[:stage].should == "demo"

      helper = AutoTagger::CapistranoHelper.new :auto_tagger_stage => "demo", :stage => "ci"
      helper.auto_tagger_options[:stage].should == "demo"
    end

    it "includes stages" do
      helper = AutoTagger::CapistranoHelper.new :auto_tagger_stages => ["demo"]
      helper.auto_tagger_options[:stages].should == ["demo"]
    end

    it "includes :auto_tagger_working_directory" do
      helper = AutoTagger::CapistranoHelper.new :auto_tagger_working_directory => "/foo"
      helper.auto_tagger_options[:path].should == "/foo"
    end

    it "includes and deprecates :working_directory" do
      AutoTagger::Deprecator.should_receive(:warn)
      helper = AutoTagger::CapistranoHelper.new :working_directory => "/foo"
      helper.auto_tagger_options[:path].should == "/foo"
    end

    [
      :date_separator,
      :push_refs,
      :fetch_refs,
      :remote,
      :ref_path,
      :offline,
      :dry_run,
      :verbose,
      :refs_to_keep,
      :executable,
      :opts_file
    ].each do |key|
      it "includes :#{key}" do
        helper = AutoTagger::CapistranoHelper.new :"auto_tagger_#{key}" => "value"
        helper.auto_tagger_options[key].should == "value"
      end
    end

  end

  describe "#stages" do
    it "understands :stages" do
      helper = AutoTagger::CapistranoHelper.new :stages => ["demo"]
      helper.stages.should == ["demo"]
    end

    it "understands :auto_tagger_stages" do
      helper = AutoTagger::CapistranoHelper.new :auto_tagger_stages => ["demo"]
      helper.auto_tagger_options[:stages].should == ["demo"]
    end

    it "understands and deprecates :autotagger_stages" do
      AutoTagger::Deprecator.should_receive(:warn)
      helper = AutoTagger::CapistranoHelper.new :autotagger_stages => ["demo"]
      helper.stages.should == ["demo"]
    end

    it "makes all stages strings" do
      helper = AutoTagger::CapistranoHelper.new :auto_tagger_stages => [:demo]
      helper.stages.should == ["demo"]
    end
  end

end

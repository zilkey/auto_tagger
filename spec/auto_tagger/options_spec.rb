require 'spec_helper'

describe AutoTagger::Options do

  describe "#parse!" do
    it "takes the first argument to be the stage" do
      options = AutoTagger::Options.parse ["ci"]
      options[:stage].should == "ci"
    end

    it "takes the second argument to be the path" do
      options = AutoTagger::Options.parse ["ci", "../"]
      options[:path].should == "../"
    end

    it "understands --tag-separator" do
      options = AutoTagger::Options.parse ["--tag-separator=|"]
      options[:ref_prefix].should == "|"
    end

    it "understands --date-format" do
      options = AutoTagger::Options.parse ["--date-format=%Y%m%d%H%M%S"]
      options[:date_format].should == "%Y%m%d%H%M%S"
    end

    it "understands --fetch-tags" do
      options = AutoTagger::Options.parse ["--fetch-tags=true"]
      options[:fetch_refs].should == true

      options = AutoTagger::Options.parse ["--fetch-tags=false"]
      options[:fetch_refs].should == false
    end

    it "understands --push-tags" do
      options = AutoTagger::Options.parse ["--push-tags=true"]
      options[:push_refs].should == true

      options = AutoTagger::Options.parse ["--push-tags=false"]
      options[:push_refs].should == false
    end

    it "understands --offline" do
      options = AutoTagger::Options.parse ["--offline"]
      options[:push_refs].should == false
      options[:fetch_refs].should == false
    end

    it "understands all help options" do
      options = AutoTagger::Options.parse ["ci"]
      options[:show_help].should be_nil

      options = AutoTagger::Options.parse []
      options[:show_help].should == true

      options = AutoTagger::Options.parse ["help"]
      options[:show_help].should == true

      options = AutoTagger::Options.parse ["-h"]
      options[:show_help].should == true

      options = AutoTagger::Options.parse ["--help"]
      options[:show_help].should == true

      options = AutoTagger::Options.parse ["-?"]
      options[:show_help].should == true
    end

    it "understands --version" do
      options = AutoTagger::Options.parse ["ci"]
      options[:show_version].should be_nil

      options = AutoTagger::Options.parse ["version"]
      options[:show_version].should == true

      options = AutoTagger::Options.parse ["--version"]
      options[:show_version].should == true

      options = AutoTagger::Options.parse ["-v"]
      options[:show_version].should == true
    end
  end

end
require 'spec_helper'

describe AutoTagger::Git::RefSet do

  before do
    @repo = mock(AutoTagger::Git::Repo, :exec => true)
    @ref_set = AutoTagger::Git::RefSet.new(@repo)
    @refstring = <<-LIST
      23087241c495773c8eece1c195cc453a8055c4eb refs/tags/200808080808
      23087241c495773c8eece1c195cc453a8055c4eb refs/tags/200808080809
    LIST
  end

  describe "#all" do
    it "returns an array of refs" do
      @repo.should_receive(:read).with("show-ref").and_return(@refstring)
      refs = @ref_set.all
      refs.length.should == 2
      refs.first.name.should == "refs/tags/200808080808"
      refs.first.sha.should == "23087241c495773c8eece1c195cc453a8055c4eb"
    end
  end

  describe "#create" do
    it "instantiates and saves a ref" do
      @repo.should_receive(:exec).with("update-ref refs/auto_tags/demo/2008 abc123")
      @ref_set.create "abc123", "refs/auto_tags/demo/2008"
    end

    it "returns the ref" do
      ref = @ref_set.create("abc123", "refs/auto_tags/demo/2008")
      ref.sha.should == "abc123"
      ref.name.should == "refs/auto_tags/demo/2008"
    end
  end

  describe "#push" do
    it "pushes all refs to the specified remote" do
      @repo.should_receive(:exec).with("push myremote refs/auto_tags/*:refs/auto_tags/*")
      @ref_set.push "refs/auto_tags/*", "myremote"
    end

    it "defaults to origin" do
      @repo.should_receive(:exec).with("push origin refs/auto_tags/*:refs/auto_tags/*")
      @ref_set.push "refs/auto_tags/*"
    end
  end

  describe "#fetch" do
    it "fetches all refs to the specified remote" do
      @repo.should_receive(:exec).with("fetch myremote refs/auto_tags/*:refs/auto_tags/*")
      @ref_set.fetch "refs/auto_tags/*", "myremote"
    end

    it "defaults to origin" do
      @repo.should_receive(:exec).with("fetch origin refs/auto_tags/*:refs/auto_tags/*")
      @ref_set.fetch "refs/auto_tags/*"
    end
  end

end

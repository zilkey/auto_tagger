require 'spec_helper'

describe AutoTagger::Git::Ref do

  before do
    @repo = mock(AutoTagger::Git::Repo, :exec => true)
    @ref = AutoTagger::Git::Ref.new(@repo, "85af4e", "refs/auto_tags/ci")
  end

  describe "#to_s" do
    it "returns the sha and the name" do
      @ref.to_s.should == "85af4e refs/auto_tags/ci"
    end
  end

  describe "#delete_locally" do
    it "sends the update ref command" do
      @repo.should_receive(:exec).with("update-ref -d refs/auto_tags/ci")
      @ref.delete_locally
    end
  end

  describe "#delete_on_remote" do
    it "pushes nothing to the remote ref" do
      @repo.should_receive(:exec).with("push myorigin :refs/auto_tags/ci")
      @ref.delete_on_remote "myorigin"
    end

    it "defaults to origin" do
      @repo.should_receive(:exec).with("push origin :refs/auto_tags/ci")
      @ref.delete_on_remote
    end
  end

  describe "#save" do
    it "should send the correct update-ref command" do
      @repo.should_receive(:exec).with("update-ref refs/auto_tags/ci 85af4e")
      @ref.save
    end

    it "returns the ref" do
      @ref.save.should == @ref
    end
  end

end
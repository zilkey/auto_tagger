require 'spec_helper'

describe AutoTagger::Commander do

  describe "#read" do
    it "execute the command and returns the results" do
      commander = AutoTagger::Commander.new("/foo", false)
      commander.should_receive(:`).with("cd /foo && ls")
      commander.read("ls")
    end
  end

  describe "#execute" do
    it "executes and doesn't return anything" do
      commander = AutoTagger::Commander.new("/foo", false)
      commander.should_receive(:system).with("cd /foo && ls")
      commander.execute("ls")
    end
  end

  describe "#print" do
    it "returns the command to be run" do
      commander = AutoTagger::Commander.new("/foo", false)
      commander.should_receive(:puts).with("cd /foo && ls")
      commander.print("ls")
    end
  end

end

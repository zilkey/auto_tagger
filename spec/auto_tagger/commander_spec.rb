require File.dirname(__FILE__) + '/../spec_helper'

describe AutoTagger::Commander do
  describe ".execute" do
    it "execute the command and returns the results" do
      mock(AutoTagger::Commander).`("cd /foo && ls") { "" } #`
      AutoTagger::Commander.execute("/foo", "ls")
    end
  end

  describe "system" do
    it "executes and doesn't return anything" do
      mock(AutoTagger::Commander).system("cd /foo && ls")
      AutoTagger::Commander.execute?("/foo", "ls")
    end
  end
end

require File.dirname(__FILE__) + '/../spec_helper'

describe Commander do
  describe ".execute" do
    it "execute the command and returns the results" do
      mock(Commander).`("cd /foo && ls") { "" } #`
      Commander.execute("/foo", "ls")
    end
  end
  
  describe "system" do
    it "executes and doesn't return anything" do
      mock(Commander).system("cd /foo && ls")
      Commander.execute!("/foo", "ls")
    end
  end
end

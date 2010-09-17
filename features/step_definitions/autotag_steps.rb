Given /^a repo$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.create_git_repo
    helpers.create_app
    @refs = helpers.refs
  end
end

When /^I run autotag with no arguments$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    @output, @exit_code = helpers.run_autotag
    @refs = helpers.refs
    @exit_code = helpers.exit_code
  end
end

When /^I run autotag with "([^\"]*)"$/ do |args|
  with_or_without_debugging do
    helpers = StepHelpers.new
    @output = helpers.run_autotag(args)
    @refs = helpers.refs
    @exit_code = helpers.exit_code
  end
end

Then /^the exit code should be "(\d+)"$/ do |code|
  @exit_code.exitstatus.should == code.to_i
end

Then /^no tags should be created$/ do
  @refs.strip.should == ""
end

Then /^a "([^\"]*)" tag should be added to git$/ do |stage|
  helpers = StepHelpers.new
  helpers.refs.split("\n").last.should match(/\/#{stage}\//)
end

Then /^a "([^\"]*)" tag should be created$/ do |prefix|
  @refs.strip.split("\n").any? { |ref| ref =~ /\/demo\// }.should be_true
end

Then /^a hyphen-delimited "([^\"]*)" tag should be created$/ do |prefix|
  tag = @refs.strip.split("\n").detect { |ref| ref =~ /\/demo\// }
  tag.split(" ").last.split("/").last.split("-").first.should == Date.today.year.to_s
end

Then /^(?:the )?exit code should be (\d*)$/ do |exit_code|
  @exit_code.should == exit_code.to_i
end
Given /^a repo$/ do
  puts
  helpers = StepHelpers.new
  helpers.create_git_repo
  helpers.create_app
  @tags = helpers.tags
  puts
end

When /^I run autotag with no arguments$/ do
  puts
  helpers = StepHelpers.new
  @output = helpers.run_autotag
  @tags = helpers.tags
  @exit_code = helpers.exit_code
  puts
end

When /^I run autotag with "([^\"]*)"$/ do |args|
  puts
  helpers = StepHelpers.new
  @output = helpers.run_autotag(args)
  @tags = helpers.tags
  @exit_code = helpers.exit_code
  puts
end

Then /^I should see "([^\"]*)"$/ do |text|
  @output.should =~ /#{Regexp.escape(text)}/
end

Then /^no tags should be created$/ do
  @tags.strip.should == ""
end

Then /^a "([^\"]*)" tag should be added to git$/ do |stage|
  helpers = StepHelpers.new
  helpers.tags.starts_with?(stage).should be_true
end

Then /^a "([^\"]*)" tag should be created$/ do |prefix|
  @tags.strip.split("\n").any?{|tag| tag.starts_with?("demo")}.should be_true
end

Then /^exit code should be (\d*)$/ do |exit_code|
  @exit_code.should == exit_code.to_i
end
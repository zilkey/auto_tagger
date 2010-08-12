Given /^a repo$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.create_git_repo
    helpers.create_app
    @tags = helpers.tags
  end
end

When /^I run autotag with no arguments$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    @output, @exit_code = helpers.run_autotag
    @tags = helpers.tags
    @exit_code = helpers.exit_code
  end
end

When /^I run autotag with "([^\"]*)"$/ do |args|
  with_or_without_debugging do
    helpers = StepHelpers.new
    @output = helpers.run_autotag(args)
    @tags = helpers.tags
    @exit_code = helpers.exit_code
  end
end

Then /^I should see "([^\"]*)"$/ do |text|
  @output.should =~ /#{Regexp.escape(text)}/
end

Then /^the exit code should be "(\d+)"$/ do |code|
  @exit_code.exitstatus.should == code.to_i
end

Then /^no tags should be created$/ do
  @tags.strip.should == ""
end

Then /^a "([^\"]*)" tag should be added to git$/ do |stage|
  helpers = StepHelpers.new
  helpers.tags.starts_with?(stage).should be_true
end

Then /^a "([^\"]*)" tag should be created$/ do |prefix|
  @tags.strip.split("\n").any? { |tag| tag.starts_with?("demo") }.should be_true
end

Then /^a hyphen-delimited "([^\"]*)" tag should be created$/ do |prefix|
  tag = @tags.strip.split("\n").detect { |tag| tag.starts_with?("demo") }
  tag.split("/").last.split("-").first.should == Date.today.year.to_s
end

Then /^(?:the )?exit code should be (\d*)$/ do |exit_code|
  @exit_code.should == exit_code.to_i
end
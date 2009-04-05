Given /^a three-stage app$/ do
  puts
  helpers = StepHelpers.new
  helpers.create_git_repo
  helpers.create_app
  helpers.create_three_stage_deployment_file
  puts
  @tags = helpers.tags
end

Given /^a ci tag$/ do
  puts
  helpers = StepHelpers.new
  helpers.autotag("ci")
  @tags = helpers.tags
  puts
end

When /^I deploy$/ do
  puts
  helpers = StepHelpers.new
  helpers.deploy
  puts
end

Then /^a tag should be added to git$/ do
  puts
  helpers = StepHelpers.new
  new_tags = helpers.tags
  @tags.length.should < new_tags.length
  puts
end
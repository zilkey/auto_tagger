Given /^a three-stage app using single deploy file$/ do
  puts
  helpers = StepHelpers.new
  helpers.create_app_with_single_deploy_file([:ci, :staging, :production])
  puts
  @tags = helpers.tags
end

Given /^a one\-stage app using single deploy file$/ do
  puts
  helpers = StepHelpers.new
  helpers.create_app_with_single_deploy_file([])
  puts
  @tags = helpers.tags
end

Given /^a three-stage app using cap-multistage$/ do
  puts
  helpers = StepHelpers.new
  helpers.create_app_with_cap_ext_multistage
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

When /^I deploy to staging$/ do
  puts
  helpers = StepHelpers.new
  helpers.deploy("staging")
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

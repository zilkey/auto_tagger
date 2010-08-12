Given /^a three-stage app using single deploy file$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.create_app_with_single_deploy_file([:ci, :staging, :production])
    @tags = helpers.tags
  end
end

Given /^a one\-stage app using single deploy file with the following environments:$/ do |table|
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.create_app_with_single_deploy_file table.raw.map(&:first)
    @tags = helpers.tags
  end
end

Given /^a three-stage app using cap-multistage$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.create_app_with_cap_ext_multistage
    @tags = helpers.tags
  end
end

Given /^a ci tag$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.autotag("ci")
    @tags = helpers.tags
  end
end

When /^I deploy to (.*)$/ do |environment|
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.deploy(environment)
  end
end

When /^I deploy$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.deploy
  end
end

Then /^a tag should be added to git$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    new_tags = helpers.tags
    @tags.length.should < new_tags.length
  end
end

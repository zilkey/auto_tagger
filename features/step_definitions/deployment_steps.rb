Given /^a three-stage app using single deploy file$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.create_app_with_single_deploy_file([:ci, :staging, :production])
    @refs = helpers.refs
  end
end

Given /^a one\-stage app using single deploy file with the following environments:$/ do |table|
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.create_app_with_single_deploy_file table.raw.map{|item| item.first}
    @refs = helpers.refs
  end
end

Given /^a three-stage app using cap-multistage$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.create_app_with_cap_ext_multistage
    @refs = helpers.refs
  end
end

Given /^an app with deploy file that uses the dsl$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.create_app_with_dsl
    @refs = helpers.refs
  end
end

Given /^a ci tag$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.autotag("ci")
    @refs = helpers.refs
  end
end

Given /^ci tags from team city$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    helpers.team_city_tag("ci", "999")
    helpers.create_and_push_another_commit
    helpers.team_city_tag("ci", "1007")
    @refs = helpers.refs
  end
end

When /^I deploy to (.*)$/ do |environment|
  with_or_without_debugging do
    helpers = StepHelpers.new
    @output = helpers.deploy(environment)
  end
end

When /^I deploy$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    @output = helpers.deploy
  end
end

Then /^a tag should be added to git$/ do
  with_or_without_debugging do
    helpers = StepHelpers.new
    new_tags = helpers.refs
    @refs.length.should < new_tags.length
  end
end

Then /^the last ci build should have been the staging tag added to git$/ do
  helpers = StepHelpers.new
  last_ref = helpers.refs.split("\n").last
  last_ref.should match(/\/staging\//)
  last_ci_ref = @refs.split("\n").detect { |ref| ref.match("1007") }

  last_ref.split(" ").first.should == last_ci_ref.split(" ").first
end
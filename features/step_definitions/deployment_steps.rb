Given /^an app$/ do
  FileUtils.mkdir_p @repo_dir
  `cd #{@repo_dir} && git --bare init`
  
  FileUtils.mkdir_p @app_dir
  
  commands = [
    "cd #{@app_dir}",
    "touch README",
    "mkdir config",
    "capify .",
    "git init",
    "git add .",
    %Q{git commit -m "first commit"},
    "git add origin file://#{@repo_dir}",
    "git push origin master"
  ]

  puts `#{commands.join(" && ")}`

  repository = "repo"
  deploy_to = "deployto"
  git_location = `which git`.strip
  environments = [:foo, :bar]

  path = File.expand_path(File.join(__FILE__, "..", "..", "templates", "deploy.erb"))
  puts path
  puts File.exists?(path)

  template = ERB.new File.read(path)
  output = template.result(binding)
  File.open(File.join(@app_dir, "config", "deploy.rb"), 'w') {|f| f.write(output) }
end

Given /^the app has the following tags:$/ do |hashes|
end

Given /^the app has the following stages:$/ do |hashes|
end

Given /^the app has the following environments:$/ do |hashes|
end

When /^I run "([^\"]*)"$/ do |arg1|
end

Then /^the app should have the following tags:$/ do |hashes|
end

Then /^the "([^\"]*)" tag should point to the same commit as the "([^\"]*)" tag$/ do |arg1, arg2|
end

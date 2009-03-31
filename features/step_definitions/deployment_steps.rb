Given /^an app$/ do
  puts "create app..."
end

Given /^the app has the following tags:$/ do |hashes|
  puts hashes.inspect
end

Given /^the app has the following stages:$/ do |hashes|
  puts hashes.inspect
end

Given /^the app has the following environments:$/ do |hashes|
  puts hashes.inspect
end

When /^I run "([^\"]*)"$/ do |arg1|
  puts arg1
end

Then /^the app should have the following tags:$/ do |hashes|
  puts hashes.inspect
end

Then /^the "([^\"]*)" tag should point to the same commit as the "([^\"]*)" tag$/ do |arg1, arg2|
  puts arg1, arg1
end

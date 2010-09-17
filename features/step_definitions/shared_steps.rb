Then /^I should see "([^\"]*)"$/ do |text|
  @output.should =~ /#{Regexp.escape(text)}/
end

Then /^I should not see "([^\"]*)"$/ do |text|
  @output.should_not =~ /#{Regexp.escape(text)}/
end


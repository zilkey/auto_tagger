Then /^I should see "([^\"]*)"$/ do |text|
  @output.should =~ /#{Regexp.escape(text)}/
end


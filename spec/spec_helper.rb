require 'rspec'
require 'rr'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "auto_tagger"))

Rspec.configure do |config|
  config.mock_with :rr
end

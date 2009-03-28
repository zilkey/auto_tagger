require 'spec'
require 'rr'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "auto_tagger"))

Spec::Runner.configure do |config|
  config.mock_with :rr
end

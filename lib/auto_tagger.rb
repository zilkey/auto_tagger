[
  'commander',
  'repository',
  'tag',
  'auto_tagger',
  'stage_manager',
  'capistrano_helper'
].each do |file|
  require File.expand_path(File.join(File.dirname(__FILE__), "auto_tagger", file))
end

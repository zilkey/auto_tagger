[
  'commander',
  'repository',
  'tag',
  'base',
  'stage_manager',
  'capistrano_helper'
].each do |file|
  require File.expand_path(File.join(File.dirname(__FILE__), "auto_tagger", file))
end

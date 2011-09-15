require 'optparse'
[
  'version',
  'deprecator',
  'git/ref',
  'git/ref_set',
  'git/repo',
  'base',
  'command_line',
  'commander',
  'configuration',
  'options',
  'capistrano_helper'
].each do |file|
  require File.expand_path(File.join(File.dirname(__FILE__), "auto_tagger", file))
end

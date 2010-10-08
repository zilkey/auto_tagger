require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "auto_tagger"
    gem.summary = %Q{Helps you automatically create tags for each stage in a multi-stage deploment and deploy from the latest tag from the previous environment}
    gem.email = "jeff@zilkey.com"
    gem.homepage = "http://github.com/zilkey/auto_tagger"
    gem.authors = ["Jeff Dean", "Brian Takita", "Mike Grafton", "Bruce Krysiak", "Pat Nakajima", "Jay Zeschin", "Mike Barinek", "Sarah Mei", "Mike Dalessio"]
    gem.add_dependency('capistrano', [">= 2.5.3"])
    gem.require_paths = ["lib"]
    gem.executables = ["autotag"]
    gem.default_executable = %q{autotag}
    gem.date = %q{2010-09-10}
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

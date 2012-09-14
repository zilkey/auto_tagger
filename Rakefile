require 'bundler'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

Bundler::GemHelper.install_tasks
RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:features)

task :default => [:spec, :features]

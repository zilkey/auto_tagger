require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "auto_tagger"
    gem.summary = %Q{Helps you automatically create tags for each stage in a multi-stage deploment and deploy from the latest tag from the previous environment}
    gem.email = "jeff@zilkey.com"
    gem.homepage = "http://github.com/zilkey/auto_tagger"
    gem.authors = ["Jeff Dean", "Brian Takita"]
    gem.add_dependency('capistrano', [">= 2.5.3"])
    gem.require_paths = ["lib", "recipes"]
    gem.executables = ["autotag"]
    gem.default_executable = %q{autotag}
    gem.date = %q{2009-03-28}
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "auto_tagger #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


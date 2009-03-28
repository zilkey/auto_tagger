# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{auto_tagger}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Dean"]
  s.date = %q{2009-03-28}
  s.default_executable = %q{autotag}
  s.executables = ["autotag"]

  files = []

  ['lib', 'recipes', 'bin', 'spec'].each do |dir|
    files += Dir.glob(File.join(File.dirname(__FILE__), dir, "**", "*"))
  end

  ['MIT-LICENSE','README.md'].each do |file|
    files << File.join(File.dirname(__FILE__), file)
  end

  s.files = files

  puts s.files

  s.email = "jeff at zilkey dot com"
  s.homepage = %q{http://github.com/zilkey/git_tagger/tree/master}
  s.require_paths = ["lib", "recipes"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Helps you automatically create tags for each stage in a multi-stage deploment and deploy from the latest tag from the previous environment}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, [">= 2.5.3"])
    else
      s.add_dependency(%q<capistrano>, [">= 2.5.3"])
    end
  else
    s.add_dependency(%q<capistrano>, [">= 2.5.3"])
  end
end

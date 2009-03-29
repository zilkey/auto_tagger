# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{auto_tagger}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Dean"]
  s.date = %q{2009-03-28}
  s.default_executable = %q{autotag}
  s.executables = ["autotag"]

  s.files = [
    "lib/auto_tagger",
    "lib/auto_tagger/auto_tagger.rb",
    "lib/auto_tagger/capistrano_helper.rb",
    "lib/auto_tagger/commander.rb",
    "lib/auto_tagger/repository.rb",
    "lib/auto_tagger/tag.rb",
    "lib/auto_tagger.rb",
    "recipes/release_tagger.rb",
    "bin/autotag",
    "spec/auto_tagger",
    "spec/auto_tagger/auto_tagger_spec.rb",
    "spec/auto_tagger/capistrano_helper_spec.rb",
    "spec/auto_tagger/commander_spec.rb",
    "spec/auto_tagger/repository_spec.rb",
    "spec/auto_tagger/tag_spec.rb",
    "spec/spec_helper.rb",
    "MIT-LICENSE",
    "README.md"
  ]

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

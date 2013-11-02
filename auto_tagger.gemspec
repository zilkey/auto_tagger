require File.expand_path('../lib/auto_tagger/version', __FILE__)

Gem::Specification.new do |s|
  s.name = %q{auto_tagger}

  s.version = AutoTagger::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Dean", "Brian Takita", "Mike Grafton", "Bruce Krysiak", "Pat Nakajima", "Jay Zeschin", "Mike Barinek", "Sarah Mei", "Mike Dalessio", "Dave Yeu", "Rachel Heaton", "Oren Weichselbaum"]
  s.date = %q{2011-09-15}
  s.default_executable = %q{autotag}
  s.email = %q{jeff@zilkey.com}
  s.executables = ["autotag"]
  s.extra_rdoc_files = ["README.md"]
  s.files = Dir.glob("{bin,lib}/**/*") + %w(MIT-LICENSE README.md CHANGELOG)
  s.homepage = %q{http://github.com/zilkey/auto_tagger}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Helps you automatically create tags for each stage in a multi-stage deploment and deploy from the latest tag from the previous environment}
  s.test_files = Dir.glob("{spec,cucumber}/**/*")

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, [">= 2.5.3", "<=2.14.2"])
    else
      s.add_dependency(%q<capistrano>, [">= 2.5.3", "<=2.14.2"])
    end
  else
    s.add_dependency(%q<capistrano>, [">= 2.5.3", "<=2.14.2"])
  end
end


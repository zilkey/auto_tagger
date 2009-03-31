require 'spec'
require 'erb'

Before do
  @root_dir = File.join(Dir.pwd, "test_files")
  @app_dir  = File.join(@root_dir, "app")
  @repo_dir = File.join(@root_dir, "repo")
  @clone    = File.join(@root_dir, "clone")

  FileUtils.rm_r(@root_dir) if File.exists?(@root_dir)
  FileUtils.mkdir_p(@root_dir)
end
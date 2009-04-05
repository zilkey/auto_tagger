class StepHelpers

  attr_reader :test_files_dir, :app_dir, :repo_dir

  def initialize
    @test_files_dir = File.join(Dir.pwd, "test_files")
    @app_dir  = File.join(test_files_dir, "app")
    @repo_dir = File.join(test_files_dir, "repo")
  end

  def reset
    FileUtils.rm_r(test_files_dir) if File.exists?(test_files_dir)
    FileUtils.mkdir_p(test_files_dir)
  end
  
  def create_git_repo
    FileUtils.mkdir_p repo_dir
    `cd #{repo_dir} && git --bare init`
  end
  
  def create_app
    FileUtils.mkdir_p app_dir
    run_commands [
      "cd #{app_dir}",
      "touch README",
      "mkdir config",
      "capify .",
      "git init",
      "git add .",
      %Q{git commit -m "first commit"},
      "git remote add origin file://#{repo_dir}",
      "git push origin master"
    ]
  end
  
  def deploy
    run_commands [
      "cd #{app_dir}",
      "cap deploy:setup",
      "cap staging deploy"
    ]
  end
  
  def autotag(stage)
    system "cd #{app_dir} && git tag #{stage}_#{Time.now.utc.strftime('%Y%m%d%H%M%S')} && git push origin --tags"
  end
  
  def tags
    system "cd #{app_dir} && git fetch origin --tags"
    tags = `cd #{app_dir} && git tag`
    puts tags
    tags
  end

  def create_three_stage_deployment_file
    repository = repo_dir
    deploy_to = File.join(test_files_dir, "deployed")
    git_location = `which git`.strip
    user = Etc.getlogin
    environments = [:ci, :staging, :production]

    path = File.expand_path(File.join(__FILE__, "..", "..", "templates", "deploy.erb"))
    puts path
    puts File.exists?(path)

    template = ERB.new File.read(path)
    output = template.result(binding)
    File.open(File.join(app_dir, "config", "deploy.rb"), 'w') {|f| f.write(output) }
  end
  
  def run_commands(commands)
    puts `#{commands.join(" && ")}`
  end
  
end
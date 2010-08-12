class StepHelpers
  attr_reader :test_files_dir, :app_dir, :repo_dir, :exit_code

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

  def create_app_with_single_deploy_file(environments)
    create_git_repo
    create_app
    capify_app
    create_single_deploy_file(environments)
  end

  def run_autotag(args = nil)
    cmd = "cd #{app_dir} && ../../bin/autotag"
    cmd += " #{args}" if args
    cmd += " 2>&1"
    output = `#{cmd}`
    puts output
    @exit_code = $?.exitstatus
    return output
  end

  def create_app_with_cap_ext_multistage
    create_git_repo
    create_app
    capify_app
    create_cap_ext_multistage_deploy_files
  end

  def deploy(stage = nil)
    deploy_command = "cap "
    deploy_command += "#{stage} " if stage
    deploy_command += "deploy"

    run_commands [
      "cd #{app_dir}",
      "cap deploy:setup",
      deploy_command
    ]
  end

  def autotag(stage)
    system "cd #{app_dir} && git tag #{stage}/#{Time.now.utc.strftime('%Y%m%d%H%M%S')} && git push origin --tags"
  end

  def tags
    system "cd #{app_dir} && git fetch origin --tags"
    tags = `cd #{app_dir} && git tag`
    puts tags
    tags
  end

  def create_app
    FileUtils.mkdir_p app_dir
    run_commands [
      "cd #{app_dir}",
      "touch README",
      "git init",
      "git add .",
      %Q{git commit -m "first commit"},
      "git remote add origin file://#{repo_dir}",
      "git push origin master"
    ]
  end

  private

  def capify_app
    run_commands [
      "cd #{app_dir}",
      "mkdir config",
      "capify ."
    ]
  end

  def create_single_deploy_file(environments)
    repository = repo_dir
    deploy_to = File.join(test_files_dir, "deployed")
    git_location = `which git`.strip
    user = Etc.getlogin
    path = File.expand_path(File.join(__FILE__, "..", "..", "templates", "deploy.erb"))
    template = ERB.new File.read(path)
    output = template.result(binding)
    File.open(File.join(app_dir, "config", "deploy.rb"), 'w') {|f| f.write(output) }
  end

  def create_cap_ext_multistage_deploy_files
    repository = repo_dir
    deploy_to = File.join(test_files_dir, "deployed")
    git_location = `which git`.strip
    user = Etc.getlogin
    environments = [:ci, :staging, :production]
    path = File.expand_path(File.join(__FILE__, "..", "..", "templates", "cap_ext_deploy.erb"))
    template = ERB.new File.read(path)
    output = template.result(binding)
    File.open(File.join(app_dir, "config", "deploy.rb"), 'w') {|f| f.write(output) }
    %w(staging production).each do |stage|
      create_cap_ext_multistage_deploy_stage_file(stage)
    end
  end

  def create_cap_ext_multistage_deploy_stage_file(stage)
    deploy_subdir = File.join(app_dir, "config", "deploy")
    FileUtils.mkdir_p deploy_subdir
    template_path = File.expand_path(File.join(__FILE__, "..", "..", "templates", "stage.erb"))
    template = ERB.new File.read(template_path)
    output = template.result(binding)
    File.open(File.join(deploy_subdir, "#{stage}.rb"), 'w') {|f| f.write(output) }
  end

  def run_commands(commands)
    puts `#{commands.join(" && ")}`
  end

end

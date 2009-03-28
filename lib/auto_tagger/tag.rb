class Tag
  
  attr_reader :repository
  
  def initialize(repository)
    @repository = repository
  end
  
  def find_all
    repository.run("git tag").split("\n")
  end
  
  def fetch
    repository.run! "git fetch origin --tags"
  end
  
  def latest_from(stage)
    find_all.select{|tag| tag =~ /^#{stage}/}.sort.last
  end

  def push
    repository.run! "git push origin --tags"
  end
    
  def create(stage)
    # git tag -a -m 'Successful continuous integration build on #{timestamp}' #{tag_name}"
    tag_name = name_for(stage)
    repository.run! "git tag #{tag_name}"
    tag_name
  end
  
  private
  
  def name_for(stage)
    "%s/%s" % [stage, Time.now.utc.strftime('%Y%m%d%H%M%S')]
  end
  
end
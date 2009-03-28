class Repository

  class NoPathProvidedError < StandardError; end
  class NoSuchPathError < StandardError; end
  class InvalidGitRepositoryError < StandardError; end
  class GitCommandFailedError < StandardError; end

  attr_reader :path

  def initialize(path)
    if path.to_s.strip == ""
      raise NoPathProvidedError
    elsif ! File.exists?(path)
      raise NoSuchPathError
    elsif ! File.exists?(File.join(path, ".git"))
      raise InvalidGitRepositoryError 
    else
      @path = path
    end
  end

  def ==(other)
    other.is_a?(Repository) && other.path == path
  end
  
  def tags
    @tags ||= Tag.new(self)
  end
  
  def run(cmd)
    Commander.execute(path, cmd)
  end

  def run!(cmd)
    Commander.execute!(path, cmd) || raise(GitCommandFailedError)
  end
  
end

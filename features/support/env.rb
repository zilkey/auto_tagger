require 'spec'
require 'erb'
require 'etc'

class String
  def starts_with?(prefix)
    self[0, prefix.length] == prefix
  end
end

Before do
  StepHelpers.new.reset
end

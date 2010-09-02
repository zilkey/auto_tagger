require 'rspec'
require 'erb'
require 'etc'

class String
  def starts_with?(prefix)
    self[0, prefix.length] == prefix
  end
end

module Silencers

  def with_or_without_debugging
    if ENV['AUTO_TAGGER_DEBUG'] == "true"
      puts
      yield
      puts
    else
      silence_stream(STDOUT) do
        silence_stream(STDERR) do
          silence_warnings do
            yield
          end
        end
      end
    end
  end

  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen(RUBY_PLATFORM =~ /(:?mswin|mingw)/ ? 'NUL:' : '/dev/null')
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
  end

  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

end

World(Silencers)

Before do
  StepHelpers.new.reset
end

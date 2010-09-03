module AutoTagger
  class Deprecator
    def self.warn(msg)
      puts string(msg)
    end

    def self.string(msg)
      "AUTO_TAGGER DEPRECATION: #{msg}"
    end
  end
end

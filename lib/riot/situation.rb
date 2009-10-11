module Riot
  class Situation
    attr_accessor :topic

    def fail(message)
      raise Failure.new(message)
    end
  end # Situation
end # Riot
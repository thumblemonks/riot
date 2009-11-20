module Riot
  class Situation
    attr_accessor :topic
    def setup(&block)
      @topic = self.instance_eval(&block)
    end

    def evaluate(&block)
      self.instance_eval(&block)
    end
  end # Situation
end # Riot

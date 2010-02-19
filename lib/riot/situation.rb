module Riot
  class Situation
    def topic
      @_topic
    end

    def setup(&block)
      @_topic = self.instance_eval(&block)
    end

    def helper(name, &block)
      (class << self; self; end).send(:define_method, name, &block)
    end

    def evaluate(&block)
      self.instance_eval(&block)
    end
  end # Situation
end # Riot

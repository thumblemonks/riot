module Riot
  class RunnableBlock
    attr_reader :definition
    def initialize(description, &definition)
      @description, @definition = description, definition || lambda { topic }
    end

    def to_s; @description; end
  end # RunnableBlock

  class Setup < RunnableBlock
    def initialize(&definition)
      super("setup", &definition)
    end

    def run(situation)
      situation.setup(&definition)
      [:setup]
    end
  end # Setup
end # Riot

module Riot
  # A runnable block is pretty much an anonymous block decorator. It's goal is to accept a block, a
  # description for what the block is intended to be for, and provide a +run+ method expects a
  # {Riot::Situation} instance. Any time a {Riot::Situation} is provided to +run+, a {Riot::RunnableBlock}
  # promises to evaluate itself against the situation in some way.
  #
  # Intent is to sub-class {Riot::RunnableBlock} with specific mechanisms for contorting the
  # {Riot::Situation}.
  class RunnableBlock

    # The decorated block.
    attr_reader :definition

    # Creates a new RunnableBlock.
    #
    # @param [String] description a description of what this block is for
    # @param [lambda] &definition the block to decorate
    def initialize(description, &definition)
      @description, @definition = description, definition || proc { false }
    end

    # Given a {Riot::Situation}, eval the provided block against it and then return a status tuple.
    #
    # @param [Riot::Situation] situation An instance of a {Riot::Situation}
    # @return [Array<Symbol[, String]>] array containing at least an evaluation state
    def run(situation)
      raise "Define your own run"
    end

    # String representation of this block, which is basically the description.
    #
    # @return [String]
    def to_s; @description; end
  end # RunnableBlock

  # Used to decorate a setup, hookup, a teardown or anything else that is about context administration.
  class Setup < RunnableBlock
    def initialize(&definition)
      super("setup", &definition)
    end

    # Calls {Riot::Situation#setup} with the predefined block at {Riot::Context} run-time. Though this is
    # like every other kind of {Riot::RunnableBlock}, +run+ will not return a meaningful state, which means
    # the reporter will likely not report anything.
    #
    # @param [Riot::Situation] situation the situation for the current {Riot::Context} run
    # @return [Array<Symbol>] array containing the evaluation state
    def run(situation)
      situation.setup(&definition)
      [:setup]
    rescue StandardError => e
      [:setup_error, e]
    end
  end # Setup

  # Used to decorate a helper. A helper generally ends up being a glorified method that can be referenced
  # from within a setup, teardown, hookup, other helpers, assertion blocks, and assertion macro blocks;
  # basically anywhere the {Riot::Situation} instance is available.
  #
  #   context "Making dinner" do
  #     helper(:easy_bake) do |thing|
  #       EasyBake.new(thing, :ingredients => [:ketchup, :chocolate, :syrup])
  #     end
  #
  #     setup do
  #       easy_bake(:meatloaf)
  #     end
  #
  #     asserts(:food_poisoning_probabilty).equals(0.947)
  #   end # Making dinner
  class Helper < RunnableBlock
    def initialize(name, &definition)
      super("helper #{name}", &definition)
      @name = name
    end

    # Calls {Riot::Situation#helper} with the predefined helper name and block at {Riot::Context} run-time.
    # Though this is like every other kind of {Riot::RunnableBlock}, +run+ will not return a meaningful
    # state, which means the reporter will likely not report anything.
    #
    # @param [Riot::Situation] situation the situation for the current {Riot::Context} run
    # @return [Array<Symbol>] array containing the evaluation state
    def run(situation)
      situation.helper(@name, &definition)
      [:helper]
    end
  end
end # Riot

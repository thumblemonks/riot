module Riot
  class RunnableBlock
    def initialize(description, &definition)
      @description, @definition = description, definition
    end

    def to_s
      @description
    end
  end # RunnableBlock

  class Setup < RunnableBlock
    def initialize(&definition)
      super("setup", &definition)
    end

    def run(situation)
      situation.setup(&@definition)
      [:setup]
    end
  end # Setup

  class Assertion < RunnableBlock
    def self.pass() [:pass]; end
    def self.fail(message) [:fail, message]; end
    def self.error(e) [:error, e]; end

    def run(situation)
      process_macro(situation) do |actual|
        actual ? Assertion.pass : Assertion.fail("Expected non-false but got #{actual.inspect} instead")
      end
    end

    def self.assertion(name, &assertion_block)
      define_method(name) do |*expectings|
        (class << self; self; end).send(:define_method, :run) do |situation|
          process_macro(situation) { |actual| assertion_block.call(actual, *expectings) }
        end # redefine run method when the assertion is called
        self
      end # define_method for assertion
    end
  private
    def process_macro(situation)
      yield(situation.evaluate(&@definition))
    rescue Exception => e
      Assertion.error(e)
    end
  end # Assertion
end # Riot

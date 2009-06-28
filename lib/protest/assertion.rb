module Protest
  class Assertion
    def initialize(description, &block)
      @description = description
      assert_block do |scope|
        actual = scope.instance_eval(&block)
        actual || failure("expected to be true, not #{actual.inspect}")
      end
    end

    def to_s; @description; end

    def assert_block(&block)
      @block = block if block_given?
      self
    end

    def run(binding_scope)
      @block.call(binding_scope)
    end

    def failure(message) raise(Protest::Failure, message); end
  end # Assertion
end # Protest
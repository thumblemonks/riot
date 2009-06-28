module Protest
  class Assertion
    def initialize(description, &block)
      @description = description
      assert_block do
        failure("expected to be true, not false") unless yield
      end
    end

    def to_s; @description; end

    def assert_block(&block)
      @block = block if block_given?
      self
    end

    def run(binding_scope)
      binding_scope.instance_eval(&@block)
    rescue Failure => e
      e
    rescue Exception => e
      raise Protest::Error.new("errored with #{e}", e)
    end
  end # Assertion
end # Protest
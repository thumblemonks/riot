module Protest
  module ContextMacros
    # def denies(description, &block)
    #   asserts(description, &block).not
    # end
  end # ContextMacros

  module AssertionMacros
    def equals(expected)
      assert_block do
        actual = yield
        failure("expected #{expected.inspect}, not #{actual.inspect}") unless expected == actual
      end
    end
    
    def nil(&block)
      equals(nil, &block)
    end

    def raises(expected)
      assert_block do
        begin
          yield
        rescue Exception => e
          failure("should have raised #{expected}, not #{e.class}") unless expected == e.class
        else
          failure("should have raised #{expected}, but raised nothing")
        end
      end
    end
    
    # def matches(matcher, &block)
    #   expectation(@expectation, &block)
    #   # equals(nil, &block)
    # end
  end # ContextMacros
end # Protest

Protest::Context.instance_eval { include Protest::ContextMacros }
Protest::Assertion.instance_eval { include Protest::AssertionMacros }
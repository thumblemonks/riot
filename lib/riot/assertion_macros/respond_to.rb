module Riot
  # Asserts that the result of the test is an object that responds to the given method
  #
  #   asserts("test") { "foo" }.respond_to(:to_s)
  #   should("test") { "foo" }.respond_to(:to_s)
  #
  # If you want to test that the result does not respond to something:
  #
  #   denies("test") { "foo" }.responds_to(:harassment)
  class RespondToMacro < AssertionMacro
    register :respond_to
    register :responds_to

    # (see Riot::AssertionMacro#evaluate)
    # @param [Symbol, String] expected the method name that actual should respond to
    def evaluate(actual, expected, include_private=false)
      if actual.respond_to?(expected, include_private)
        pass new_message.responds_to(expected, include_private)
      else
        fail(expected_message.method(expected, include_private).is_not_defined)
      end
    end
    
    # (see Riot::AssertionMacro#devaluate)
    # @param [Symbol, String] expected the method name that actual should not respond to
    def devaluate(actual, expected, include_private=false)
      if actual.respond_to?(expected, include_private)
        fail(expected_message.method(expected, include_private).is_defined)
      else
        pass new_message.responds_to(expected, include_private)
      end
    end
    
  end
end

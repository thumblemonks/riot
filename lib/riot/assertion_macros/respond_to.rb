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

    def evaluate(actual, expected)
      if actual.respond_to?(expected)
        pass(new_message.responds_to(expected))
      else
        fail(expected_message.method(expected).is_not_defined)
      end
    end
    
    def devaluate(actual, expected)
      if actual.respond_to?(expected)
        fail(expected_message.method(expected).is_defined)
      else
        pass new_message.does_not_respond_to(expected)
      end
    end
    
  end
end

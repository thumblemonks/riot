module Riot
  # Asserts that the result of the test is an object that responds to the given method
  #   asserts("test") { "foo" }.respond_to(:to_s)
  #   should("test") { "foo" }.respond_to(:to_s)
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
  end
end

module Riot
  # Asserts that the result of the test is an object that responds to the given method
  #   asserts("test") { "foo" }.respond_to(:to_s)
  #   should("test") { "foo" }.respond_to(:to_s)
  class RespondToMacro < AssertionMacro
    def evaluate(actual, expected)
      actual.respond_to?(expected) ? pass : fail("expected method #{expected.inspect} is not defined")
    end
  end
  
  Assertion.register_macro :respond_to, RespondToMacro
end

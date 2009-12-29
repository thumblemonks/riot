module Riot
  # Asserts the result has items
  #   asserts("an array") { [1] }.any
  #   asserts("a hash") { {:name => 'washington'} }.any
  class AnyMacro < AssertionMacro
    def evaluate(actual)
      actual.any? ? pass("is not empty") : fail("expected #{actual.inspect} to have items")
    end
  end
  
  Assertion.register_macro :any, AnyMacro
end

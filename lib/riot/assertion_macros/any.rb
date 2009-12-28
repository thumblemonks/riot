module Riot
  # Asserts the result has items
  #   asserts("an array") { [1] }.any
  #   asserts("a hash") { {:name => 'washington'} }.any
  class AnyMacro < AssertionMacro
    def evaluate(actual)
      actual.any? ? pass : fail("expected #{actual.inspect} to have items")
    end

    def template
      "%s is not empty"
    end
  end
  
  Assertion.register_macro :any, AnyMacro
end

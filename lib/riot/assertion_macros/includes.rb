module Riot
  # Asserts the result contains the expected element
  #   asserts("a string") { "world" }.includes('o')
  #   asserts("an array") { [1,2,3] }.includes(2)
  #   asserts("a range") { (1..15) }.includes(10)
  class IncludesMacro < AssertionMacro
    def evaluate(actual, expected)
      actual.include?(expected) ? pass : fail("expected #{actual.inspect} to include #{expected.inspect}")
    end
  end
  
  Assertion.register_macro :includes, IncludesMacro
end

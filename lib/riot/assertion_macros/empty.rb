module Riot
  # Asserts the result is empty
  #   asserts("a string") { "" }.empty
  #   asserts("an array") { [] }.empty
  #   asserts("a hash") { Hash.new }.empty
  class EmptyMacro < AssertionMacro
    def evaluate(actual)
      actual.length == 0 ? pass : fail("expected #{actual.inspect} to be empty")
    end
  end
  
  Assertion.register_macro :empty, EmptyMacro
end

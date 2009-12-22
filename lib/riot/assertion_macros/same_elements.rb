module Riot
  # Asserts that two arrays contain the same elements, the same number of times.
  #   asserts("test") { ["foo", "bar"] }.same_elements(["bar", "foo"])
  #   should("test") { ["foo", "bar"] }.same_elements(["bar", "foo"])
  class SameElementsMacro < AssertionMacro
    def evaluate(actual, expected)
      require 'set'
      same = (Set.new(expected) == Set.new(actual))
      same ? pass : fail("expected elements #{expected.inspect} to match #{actual.inspect}")
    end
  end
  
  Assertion.register_macro :same_elements, SameElementsMacro
end

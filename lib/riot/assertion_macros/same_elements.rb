module Riot
  # Asserts that two arrays contain the same elements, the same number of times.
  #   asserts("test") { ["foo", "bar"] }.same_elements(["bar", "foo"])
  #   should("test") { ["foo", "bar"] }.same_elements(["bar", "foo"])
  class SameElementsMacro < AssertionMacro
    register :same_elements

    def evaluate(actual, expected)
      require 'set'
      same = (Set.new(expected) == Set.new(actual))
      same ? pass : fail(expected_message.elements(expected).to_match(actual))
    end
  end
end

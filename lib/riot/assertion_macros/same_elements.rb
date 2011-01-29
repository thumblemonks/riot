module Riot
  # Asserts that two arrays contain the same elements, the same number of times.
  #
  #   asserts("test") { ["foo", "bar"] }.same_elements(["bar", "foo"])
  #   should("test") { ["foo", "bar"] }.same_elements(["bar", "foo"])
  #
  # Maybe you just want to make sure two sets arent't the same:
  #
  #  denies("test") { ["foo", "bar"] }.same_elements(["baz", "boo"])
  class SameElementsMacro < AssertionMacro
    register :same_elements
    require 'set'
    
    # (see Riot::AssertionMacro#evaluate)
    # @param [Object] expected the collection of elements that actual should be equivalent to
    def evaluate(actual, expected)
      same = (Set.new(expected) == Set.new(actual))
      same ? pass : fail(expected_message.elements(expected).to_match(actual))
    end

    # (see Riot::AssertionMacro#devaluate)
    # @param [Object] expected the collection of elements that actual should not be equivalent to
    def devaluate(actual, expected)
      same = (Set.new(expected) == Set.new(actual))
      same ? fail(expected_message.elements(expected).not_to_match(actual)) : pass
    end

  end
end

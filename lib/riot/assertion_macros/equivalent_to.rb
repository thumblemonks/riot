module Riot
  # Asserts that the result of the test is equivalent to the expected value. Using the +===+ operator.
  #
  #   asserts("test") { "foo" }.equivalent_to(String)
  #   should("test") { "foo" }.equivalent_to("foo")
  #   asserts("test") { "foo" }.equivalent_to { "foo" }
  #
  # You can also assert that the expected value is not equivalent to something else:
  #
  #   denies("test") { "foo" }.equivalent_to(Boolean)
  #   denies("test") { "foo" }.equivalent_to("bar")
  #
  # Underneath the hood, this assertion macro uses:
  #
  #   expected === actual
  class EquivalentToMacro < AssertionMacro
    register :equivalent_to

    # (see Riot::AssertionMacro#evaluate)
    # @param [Object] expected the object value to compare actual to
    def evaluate(actual, expected)
      if expected === actual
        pass new_message.is_equivalent_to(expected)
      else
        fail expected_message(actual).to_be_equivalent_to(expected)
      end
    end
    
    # (see Riot::AssertionMacro#devaluate)
    # @param [Object] expected the object value to compare actual to
    def devaluate(actual, expected)
      if expected === actual
        fail expected_message(actual).not_to_be_equivalent_to(expected)
      else
        pass new_message.is_not_equivalent_to(expected)
      end
    end
    
  end
end

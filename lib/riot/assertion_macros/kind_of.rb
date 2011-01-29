module Riot
  # Asserts that the result of the test is an object that is a kind of the expected type
  #
  #   asserts("test") { "foo" }.kind_of(String)
  #   should("test") { "foo" }.kind_of(String)
  #
  # You can also test the result is not a kind of a thing:
  #
  #   denies("test") { "foo" }.kind_of(Boolean)
  class KindOfMacro < AssertionMacro
    register :kind_of

    # (see Riot::AssertionMacro#evaluate)
    # @param [Class] expected the expected class of actual
    def evaluate(actual, expected)
      if actual.kind_of?(expected)
        pass new_message.is_a_kind_of(expected)
      else
        fail expected_message.kind_of(expected).not(actual.class)
      end
    end
    
    # (see Riot::AssertionMacro#devaluate)
    # @param [Class] expected the unexpected class of actual
    def devaluate(actual, expected)
      if actual.kind_of?(expected)
        fail expected_message.not_kind_of(expected).not(actual.class)
      else
        pass new_message.is_not_a_kind_of(expected)
      end
    end
  end
end

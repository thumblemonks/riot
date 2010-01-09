module Riot
  # Asserts that the result of the test is equivalent to the expected value. Using the +===+ operator.
  #
  #   asserts("test") { "foo" }.equivalent_to(String)
  #   should("test") { "foo" }.equals("foo")
  #   asserts("test") { "foo" }.equals { "foo" }
  #
  # Underneath the hood, this assertion macro says:
  #
  #   expected === actual
  class EquivalentToMacro < AssertionMacro
    register :equivalent_to

    def evaluate(actual, expected)
      if expected === actual
        pass new_message.is_equivalent_to(expected)
      else
        fail expected_message(actual).to_be_equivalent_to(expected)
      end
    end
  end
end

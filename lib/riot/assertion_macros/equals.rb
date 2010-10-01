module Riot
  # Asserts that the result of the test equals the expected value. Using the +==+ operator to assert
  # equality.
  #   asserts("test") { "foo" }.equals("foo")
  #   should("test") { "foo" }.equals("foo")
  #   asserts("test") { "foo" }.equals { "foo" }
  class EqualsMacro < AssertionMacro
    register :equals

    def evaluate(actual, expected)
      if expected == actual
        pass new_message.is_equal_to(expected)
      else
        fail expected_message(expected).not(actual)
      end
    end

    def devaluate(actual, expected)
      if expected != actual
        pass new_message.is_equal_to(expected).when_it_is(actual)
      else
        fail new_message.did_not_expect(actual)
      end
    end
  end
end

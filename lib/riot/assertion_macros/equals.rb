module Riot
  # Asserts that the result of the test equals the expected value. Using the +===+ operator to assert
  # equality.
  #   asserts("test") { "foo" }.equals("foo")
  #   should("test") { "foo" }.equals("foo")
  #   asserts("test") { "foo" }.equals { "foo" }
  class EqualsMacro < AssertionMacro
    register :equals

    def evaluate(actual, expected)
      if expected === actual
        pass("is equal to #{expected.inspect}")
      else
        fail("expected #{expected.inspect}, not #{actual.inspect}")
      end
    end
  end
end

module Riot
  # Asserts that the result of the test equals the expected value. Using the +===+ operator to assert
  # equality.
  #   asserts("test") { "foo" }.equals("foo")
  #   should("test") { "foo" }.equals("foo")
  #   asserts("test") { "foo" }.equals { "foo" }
  class EqualsMacro < AssertionMacro
    def evaluate(actual, expected)
      expected === actual ? pass : fail("expected #{expected.inspect}, not #{actual.inspect}")
    end
  end
  
  Assertion.register_macro :equals, EqualsMacro
end

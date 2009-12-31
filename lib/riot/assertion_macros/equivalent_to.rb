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
        pass("is equivalent to #{expected.inspect}")
      else
        fail("expected #{actual.inspect} to be equivalent to #{expected.inspect}")
      end
    end
  end
end

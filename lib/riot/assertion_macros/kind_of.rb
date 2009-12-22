module Riot
  # Asserts that the result of the test is an object that is a kind of the expected type
  #   asserts("test") { "foo" }.kind_of(String)
  #   should("test") { "foo" }.kind_of(String)
  class KindOfMacro < AssertionMacro
    def evaluate(actual, expected)
      actual.kind_of?(expected) ? pass : fail("expected kind of #{expected}, not #{actual.class.inspect}")
    end
  end
  
  Assertion.register_macro :kind_of, KindOfMacro
end

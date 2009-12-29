module Riot
  # Asserts that the result of the test is an object that is a kind of the expected type
  #   asserts("test") { "foo" }.kind_of(String)
  #   should("test") { "foo" }.kind_of(String)
  class KindOfMacro < AssertionMacro
    register :kind_of

    def evaluate(actual, expected)
      if actual.kind_of?(expected)
        pass("is a kind of #{expected.inspect}")
      else
        fail("expected kind of #{expected}, not #{actual.class.inspect}")
      end
    end
  end
end

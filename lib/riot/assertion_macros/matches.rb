module Riot
  # Asserts that the result of the test equals matches against the proved expression
  #   asserts("test") { "12345" }.matches(/\d+/)
  #   should("test") { "12345" }.matches(/\d+/)
  class MatchesMacro < AssertionMacro
    register :matches

    def evaluate(actual, expected)
      expected = %r[#{Regexp.escape(expected)}] if expected.kind_of?(String)
      if actual =~ expected
        pass("matches #{expected.inspect}")
      else
        fail("expected #{expected.inspect} to match #{actual.inspect}")
      end
    end
  end
end

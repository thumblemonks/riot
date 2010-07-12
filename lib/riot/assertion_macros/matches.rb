module Riot
  # Asserts that the result of the test equals matches against the proved expression
  #   asserts("test") { "12345" }.matches(/\d+/)
  #   should("test") { "12345" }.matches(/\d+/)
  class MatchesMacro < AssertionMacro
    register :matches

    def evaluate(actual, expected)
      expected = %r[#{Regexp.escape(expected)}] if expected.kind_of?(String)
      if actual.to_s =~ expected
        pass(new_message.matches(expected))
      else
        fail(expected_message(expected).to_match(actual))
      end
    end
  end
end

module Riot
  # Asserts that the result of the test equals matches against the proved expression
  #
  #   asserts("test") { "12345" }.matches(/\d+/)
  #   should("test") { "12345" }.matches(/\d+/)
  #
  # You can also test that the result does not match your regex:
  #
  #   denies("test") { "hello, world"}.matches(/\d+/)
  class MatchesMacro < AssertionMacro
    register :matches

    # (see Riot::AssertionMacro#evaluate)
    # @param [Regex, String] expected the string or regex to be used in comparison
    def evaluate(actual, expected)
      expected = %r[#{Regexp.escape(expected)}] if expected.kind_of?(String)
      if actual.to_s =~ expected
        pass(new_message.matches(expected))
      else
        fail(expected_message(expected).to_match(actual))
      end
    end
    
    # (see Riot::AssertionMacro#devaluate)
    # @param [Regex, String] expected the string or regex to be used in comparison
    def devaluate(actual, expected)
      expected = %r[#{Regexp.escape(expected)}] if expected.kind_of?(String)
      if actual.to_s =~ expected
        fail(expected_message(expected).not_to_match(actual))
      else
        pass(new_message.matches(expected))
      end
    end
  end
end

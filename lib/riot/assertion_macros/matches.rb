module Riot
  # Asserts that the result of the test equals matches against the proved expression
  #   asserts("test") { "12345" }.matches(/\d+/)
  #   should("test") { "12345" }.matches(/\d+/)
  class MatchesMacro < AssertionMacro
    def evaluate(actual, expected)
      expected = %r[#{Regexp.escape(expected)}] if expected.kind_of?(String)
      actual =~ expected ? pass : fail("expected #{expected.inspect} to match #{actual.inspect}")
    end

    def template(expression)
      "%s matches #{expression.inspect}"
    end
  end

  Assertion.register_macro :matches, MatchesMacro
end

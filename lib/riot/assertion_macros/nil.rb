module Riot
  # Asserts that the result of the test is nil
  #   asserts("test") { nil }.nil
  #   should("test") { nil }.nil
  class NilMacro < AssertionMacro
    def evaluate(actual)
      actual.nil? ? pass : fail("expected nil, not #{actual.inspect}")
    end

    def template
      "%s is nil"
    end
  end
  
  Assertion.register_macro :nil, NilMacro
end

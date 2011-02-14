module Riot
  # Asserts that the result of the test is nil
  #
  #   asserts("test") { nil }.nil
  #   should("test") { nil }.nil
  #
  # You could test that the result is not nil, but it would make more sense to use the +exists+ macro:
  #
  #   denies("test") { "foo" }.nil
  #   asserts("test") { "foo" }.exists
  class NilMacro < AssertionMacro
    register :nil

    # (see Riot::AssertionMacro#evaluate)
    def evaluate(actual)
      actual.nil? ? pass("is nil") : fail(expected_message.nil.not(actual))
    end
    
    # (see Riot::AssertionMacro#devaluate)
    def devaluate(actual)
      actual.nil? ? fail(expected_message.is_nil.not('non-nil')) : pass("is nil")
    end
  end
end

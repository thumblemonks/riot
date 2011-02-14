module Riot
  # Asserts that the result of the test is a non-nil value. This is useful in the case where you don't want
  # to translate the result of the test into a boolean value
  #
  #   asserts("test") { "foo" }.exists
  #   should("test") { 123 }.exists
  #   asserts("test") { "" }.exists
  #   asserts("test") { nil }.exists # This would fail
  #
  # You can also test for non-existince (being nil), but if you would better if you used the +nil+ macro:
  #
  #   denies("test") { nil }.exists # would pass
  #   asserts("test") { nil }.nil   # same thing
  #
  #   denies("test") { "foo" }.exists # would fail
  class ExistsMacro < AssertionMacro
    register :exists

    # (see Riot::AssertionMacro#evaluate)
    def evaluate(actual)
      actual.nil? ? fail("expected a non-nil value") : pass("does exist")
    end
    
    # (see Riot::AssertionMacro#devaluate)
    def devaluate(actual)
      actual.nil? ? pass("does exist") : fail("expected a nil value")
    end
  end
end

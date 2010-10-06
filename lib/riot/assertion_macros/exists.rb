module Riot
  # Asserts that the result of the test is a non-nil value. This is useful in the case where you don't want
  # to translate the result of the test into a boolean value
  #   asserts("test") { "foo" }.exists
  #   should("test") { 123 }.exists
  #   asserts("test") { "" }.exists
  #   asserts("test") { nil }.exists # This would fail
  class ExistsMacro < AssertionMacro
    register :exists

    def evaluate(actual)
      !actual.nil? ? pass("is not nil") : fail("expected a non-nil value")
    end
    
    def devaluate(actual)
      !actual.nil? ? fail("expected a nil value") : pass("is nil")
    end
    
  end
end

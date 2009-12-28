module Riot
  # Asserts that the result of the test is a non-nil value. This is useful in the case where you don't want
  # to translate the result of the test into a boolean value
  #   asserts("test") { "foo" }.exists
  #   should("test") { 123 }.exists
  #   asserts("test") { "" }.exists
  #   asserts("test") { nil }.exists # This would fail
  class ExistsMacro < AssertionMacro
    def evaluate(actual)
      !actual.nil? ? pass : fail("expected a non-nil value")
    end

    def template
      "%s is not nil"
    end
  end
  
  Assertion.register_macro :exists, ExistsMacro
end

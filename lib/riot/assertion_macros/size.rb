module Riot
  # Asserts that result's size is as expected. Expected size can be specified as
  # a number or a range.
  #   asserts("a string") { 'washington' }.size(9..12)
  #   asserts("an array") { [1, 2, 3] }.size(3)
  #   asserts("a hash") { {:name => 'washington'} }.size(1)
  class SizeMacro < AssertionMacro
    def evaluate(actual, expected)
      failure_message = "size of #{actual.inspect} expected to be #{expected} but is #{actual.size}"
      expected === actual.size ? pass("is of size #{expected}") : fail(failure_message)
    end
  end
  
  Assertion.register_macro :size, SizeMacro
end

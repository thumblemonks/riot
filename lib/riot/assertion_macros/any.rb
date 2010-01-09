module Riot
  # Asserts the result has items
  #   asserts("an array") { [1] }.any
  #   asserts("a hash") { {:name => 'washington'} }.any
  class AnyMacro < AssertionMacro
    register :any

    def evaluate(actual)
      actual.any? ? pass("is not empty") : fail(expected_message(actual).to_have_items)
    end
  end
end

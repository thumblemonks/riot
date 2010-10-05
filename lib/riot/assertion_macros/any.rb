module Riot
  # In the positive case, asserts the result has items using the +any?+ operator.
  #
  #   asserts("an array") { [1] }.any
  #   asserts("a hash") { {:name => 'washington'} }.any
  #
  # In the negative case, asserts the result has no items using the +any?+ operator.
  #
  #   denies("an empty array") { [] }.any
  #   denies("an empty hash") { {} }.any
  class AnyMacro < AssertionMacro
    register :any

    def evaluate(actual)
      actual.any? ? pass("is not empty") : fail(expected_message(actual).to_have_items)
    end

    def devaluate(actual)
      actual.any? ? fail(expected_message(actual).not_to_have_elements) : pass("has elements")
    end
  end
end

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

    # (see Riot::AssertionMacro#evaluate)
    def evaluate(actual)
      any?(actual) ? pass("has items") : fail(expected_message(actual).to_have_items)
    end

    # (see Riot::AssertionMacro#devaluate)
    def devaluate(actual)
      any?(actual) ? fail(expected_message(actual).not_to_have_items) : pass("has items")
    end
  private
    def any?(object)
      object.kind_of?(String) ? object.length > 0 : object.any?
    end
  end
end

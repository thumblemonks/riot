module Riot
  # In the postive case, asserts the result of the test is empty.
  #
  #   asserts("a string") { "" }.empty
  #   asserts("an array") { [] }.empty
  #   asserts("a hash") { Hash.new }.empty
  #
  # In the negative case, asserts the result of the test is not empty.
  #
  #   denies("a string") { "foo" }.empty
  #   denies("an array") { [1] }.empty
  #   denies("a hash") { {:foo => "bar" } }.empty
  class EmptyMacro < AssertionMacro
    register :empty

    def evaluate(actual)
      actual.empty? ? pass(new_message.is_empty) : fail(expected_message(actual).to_be_empty)
    end

    def devaluate(actual)
      actual.empty? ? fail(expected_message(actual).to_not_be_empty) : pass(new_message.is_empty)
    end
  end
end

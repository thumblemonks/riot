module Riot
  # Asserts the result is empty
  #   asserts("a string") { "" }.empty
  #   asserts("an array") { [] }.empty
  #   asserts("a hash") { Hash.new }.empty
  class EmptyMacro < AssertionMacro
    register :empty

    def evaluate(actual)
      actual.length == 0 ? pass : fail(expected_message(actual).to_be_empty)
    end
  end
end

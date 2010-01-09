module Riot
  # Asserts the result contains the expected element
  #   asserts("a string") { "world" }.includes('o')
  #   asserts("an array") { [1,2,3] }.includes(2)
  #   asserts("a range") { (1..15) }.includes(10)
  class IncludesMacro < AssertionMacro
    register :includes

    def evaluate(actual, expected)
      if actual.include?(expected)
        pass new_message.includes(expected)
      else
        fail expected_message(actual).to_include(expected)
      end
    end
  end
end

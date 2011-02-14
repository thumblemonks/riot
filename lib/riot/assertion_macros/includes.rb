module Riot
  # Asserts the result contains the expected element
  #
  #   asserts("a string") { "world" }.includes('o')
  #   asserts("an array") { [1,2,3] }.includes(2)
  #   asserts("a range") { (1..15) }.includes(10)
  #
  # You can also assert that the result does not contain an element:
  #
  #   denies("a string") { "world" }.includes('f')
  #   denies("an array") { [1,2,3,4,5] }.includes(0)
  #   denies("a range") { (1..15) }.includes(16)
  class IncludesMacro < AssertionMacro
    register :includes

    # (see Riot::AssertionMacro#evaluate)
    # @param [Object] expected the object that is expected to be included
    def evaluate(actual, expected)
      if actual.include?(expected)
        pass new_message.includes(expected)
      else
        fail expected_message(actual).to_include(expected)
      end
    end
    
    # (see Riot::AssertionMacro#devaluate)
    # @param [Object] expected the object that is not expected to be included
    def devaluate(actual, expected)
      if actual.include?(expected)
        fail expected_message(actual).to_not_include(expected)
      else
        pass new_message.includes(expected)
      end
    end
    
  end
end

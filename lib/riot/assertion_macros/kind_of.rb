module Riot
  # Asserts that the result of the test is an object that is a kind of the expected type
  #   asserts("test") { "foo" }.kind_of(String)
  #   should("test") { "foo" }.kind_of(String)
  class KindOfMacro < AssertionMacro
    register :kind_of

    def evaluate(actual, expected)
      if actual.kind_of?(expected)
        pass new_message.is_a_kind_of(expected)
      else
        fail expected_message.kind_of(expected).not(actual.class)
      end
    end
  end
end

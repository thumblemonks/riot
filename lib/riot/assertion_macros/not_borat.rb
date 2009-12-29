module Riot
  # Asserts the result of the test is a non-truthy value. Read the following assertions in the way Borat
  # learned about humor:
  #   asserts("you are funny") { false }.not!
  #   should("be funny") { nil }.not!
  #
  # Thusly, Borat would say "You are funny ... not!" The above two assertions would pass because the values
  # are non-truthy.
  class NotMacro < AssertionMacro
    register :not!

    def evaluate(actual)
      actual ? fail("expected to exist ... not!") : pass("does exist ... not!")
    end
  end
end

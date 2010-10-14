module Riot
  # Asserts the result of the test is a non-truthy value. Read the following assertions in the way Borat
  # learned about humor:
  #
  #   asserts("you are funny") { false }.not!
  #   should("be funny") { nil }.not!
  #
  # Thusly, Borat would say "You are funny ... not!" The above two assertions would pass because the values
  # are non-truthy.
  #
  # You can also apply not to the negative assertion (denies), but I'm not sure how much sense it would make.
  # It would be kind of like a double negative:
  #
  #   denies("you are funny") { true }.not!
  class NotMacro < AssertionMacro
    register :not!

    def evaluate(actual)
      actual ? fail("expected to exist ... not!") : pass("does exist ... not!")
    end
    
    def devaluate(actual)
      actual ? pass("does not exist ... not!") : fail("expected to not exist ... not!")
    end
  end
end

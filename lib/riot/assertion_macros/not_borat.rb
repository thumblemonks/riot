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
  #
  # @deprecated Please use the denies assertion instead
  class NotMacro < AssertionMacro
    register :not!

    # (see Riot::AssertionMacro#evaluate)
    def evaluate(actual)
      warn "not! is deprecated; please use the denies assertion instead"
      actual ? fail("expected to exist ... not!") : pass("does exist ... not!")
    end
    
    # (see Riot::AssertionMacro#devaluate)
    def devaluate(actual)
      warn "not! is deprecated; please use the denies assertion instead"
      actual ? pass("does not exist ... not!") : fail("expected to not exist ... not!")
    end
  end
end

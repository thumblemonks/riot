module Riot
  # Asserts that the test raises the expected exception, or one of its
  # subclasses. Thus, the following assertions pass:
  #   asserts("test") { raise My::Exception }.raises(My::Exception)
  #   should("test") { raise My::Exception }.raises(My::Exception.superclass)
  # The following, however, fails:
  #   asserts("test") { raise My::Exception.superclass }.raises(My::Exception)
  #
  # You can also check to see if the provided message equals or matches your
  # expectations. The message from the actual raised exception will be converted
  # to a string before any comparison is executed.
  #   asserts("test") { raise My::Exception, "Foo" }.raises(My::Exception, "Foo")
  #   asserts("test") { raise My::Exception, "Foo Bar" }.raises(My::Exception, /Bar/)
  #
  # You can use the negative form to assert that no exception is raised at all:
  #   denies("test") {
  #     # do stuff
  #   }.raises_kind_of Exception
  #
  # It can be used to check that a particular class of exception is not raised,
  # in which case you should be aware that raising another kind of exception
  # will *not* produce a failure.
  #   denies("test") { raises ArgumentError }.raises_kind_of ArgumentError # fails
  #   denies("test") { raises Class.new(ArgumentError) }.raises_kind_of ArgumentError # fails
  #   denies("test") { raises "this doesn't work" }.raises_kind_of ArgumentError # passes
  class RaisesKindOfMacro < AssertionMacro
    register :raises_kind_of
    expects_exception!

    # (see Riot::AssertionMacro#evaluate)
    # @param [Class] expected_class the expected Exception class
    # @param [String, nil] expected_message an optional exception message or message partial
    def evaluate(actual_exception, expected_class, expected_message=nil)
      actual_message = actual_exception && actual_exception.message

      if !actual_exception
        fail new_message.expected_to_raise_kind_of(expected_class).but.raised_nothing
      elsif !actual_exception.is_a?(expected_class)
        fail new_message.expected_to_raise_kind_of(expected_class).not(actual_exception.class)
      elsif expected_message && !(actual_message.to_s =~ %r[#{expected_message}])
        fail expected_message(expected_message).for_message.not(actual_message)
      else
        message = new_message.raises_kind_of(expected_class)
        pass(expected_message ? message.with_message(expected_message) : message)
      end
    end # evaluate

    # (see Riot::AssertionMacro#devaluate)
    # @param [Class] expected_class the unexpected Exception class
    # @param [String, nil] expected_message an optional exception message or message partial
    def devaluate(actual_exception, expected_class, expected_message=nil)
      actual_message = actual_exception && actual_exception.message

      if !actual_exception
        pass new_message.raises_kind_of(expected_class)
      elsif !actual_exception.is_a?(expected_class)
        if expected_message && !(actual_message.to_s =~ %r[#{expected_message}])
          pass new_message.raises_kind_of(expected_class).
            with_message(expected_message)
        else
          pass new_message.raises_kind_of(expected_class)
        end
      else
        message = new_message.expected_to_not_raise_kind_of(expected_class)

        if expected_message
          fail message.with_message(expected_message).but.
            raised(actual_exception.class).
            with_message(actual_exception.message)
        else
          fail message
        end
      end
    end # devaluate
  end # RaisesMacro
end

module Riot
  # Asserts that the test raises the expected Exception
  #   asserts("test") { raise My::Exception }.raises(My::Exception)
  #   should("test") { raise My::Exception }.raises(My::Exception)
  #
  # You can also check to see if the provided message equals or matches your expectations. The message
  # from the actual raised exception will be converted to a string before any comparison is executed.
  #   asserts("test") { raise My::Exception, "Foo" }.raises(My::Exception, "Foo")
  #   asserts("test") { raise My::Exception, "Foo Bar" }.raises(My::Exception, /Bar/)
  #
  # In the negative case, you can test that an exception was not raised or that if an exception was raised
  # that the type of exception was different (sounds confusing).
  #
  #   denies("test") { "foo" }.raises(Exception) # would pass
  #   denies("test") { raise Exception }.raises(My::Exception) # would pass
  #   denies("test") { raise Exception }.raises(Exception) # would fail
  class RaisesMacro < AssertionMacro
    register :raises
    expects_exception!

    # (see Riot::AssertionMacro#evaluate)
    # @param [Class] expected_class the expected Exception class
    # @param [String, nil] expected_message an optional exception message or message partial
    def evaluate(actual_exception, expected_class, expected_message=nil)
      actual_message = actual_exception && actual_exception.message
      if actual_exception.nil?
        fail new_message.expected_to_raise(expected_class).but.raised_nothing
      elsif expected_class != actual_exception.class
        fail new_message.expected_to_raise(expected_class).not(actual_exception.class)
      elsif expected_message && !(actual_message.to_s =~ %r[#{expected_message}])
        fail expected_message(expected_message).for_message.not(actual_message)
      else
        message = new_message.raises(expected_class)
        pass(expected_message ? message.with_message(expected_message) : message)
      end
    end # evaluate

    # (see Riot::AssertionMacro#devaluate)
    # @param [Class] expected_class the unexpected Exception class
    # @param [String, nil] expected_message an optional exception message or message partial
    def devaluate(actual_exception, expected_class, expected_message=nil)
      actual_message = actual_exception && actual_exception.message
      if actual_exception.nil?
        pass new_message.raises(expected_class)
      elsif expected_class != actual_exception.class
        if expected_message && !(actual_message.to_s =~ %r[#{expected_message}])
          pass new_message.raises(expected_class).with_message(expected_message)
        else
          pass new_message.raises(expected_class)
        end
      else
        message = new_message.expected_to_not_raise(expected_class)
        if expected_message
          fail message.with_message(expected_message).but.raised(actual_exception.class).
            with_message(actual_exception.message)
        else
          fail message
        end
      end
    end # devaluate
  end # RaisesMacro
end

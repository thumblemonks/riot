module Riot
  # Asserts that the test raises the expected Exception
  #   asserts("test") { raise My::Exception }.raises(My::Exception)
  #   should("test") { raise My::Exception }.raises(My::Exception)
  #
  # You can also check to see if the provided message equals or matches your expectations. The message
  # from the actual raised exception will be converted to a string before any comparison is executed.
  #   asserts("test") { raise My::Exception, "Foo" }.raises(My::Exception, "Foo")
  #   asserts("test") { raise My::Exception, "Foo Bar" }.raises(My::Exception, /Bar/)
  class RaisesMacro < AssertionMacro
    register :raises
    expects_exception!

    def evaluate(actual_exception, expected_class, expected_message=nil)
      actual_message = actual_exception && actual_exception.message
      if actual_exception.nil?
        fail should_have_message.raised(expected_class).but.raised_nothing
      elsif expected_class != actual_exception.class
        fail should_have_message.raised(expected_class).not(actual_exception.class)
      elsif expected_message && !(actual_message.to_s =~ %r[#{expected_message}])
        fail expected_message(expected_message).for_message.not(actual_message)
      else
        message = new_message.raises(expected_class)
        pass(expected_message ? message.with_message(expected_message) : message)
      end
    end # evaluate

    def devaluate(actual_exception, expected_class, expected_message=nil)
      actual_message = actual_exception && actual_exception.message
      if actual_exception.nil?
        pass new_message.raised_nothing
      elsif expected_class != actual_exception.class
        if expected_message && !(actual_message.to_s =~ %r[#{expected_message}])
          pass new_message.not_raised(expected_class).with_message(expected_message)
        else
          pass new_message.not_raised(expected_class)
        end
      else
        message = should_have_message.not_raised(expected_class)
        full_msg =
        if expected_message
          message.with_message(expected_message).but.raised(actual_exception.class).with_message(actual_exception.message)
        else
          message.but.raised(actual_exception.class)
        end
        fail full_msg
      end
    end # devaluate
  end # RaisesMacro
end

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
    def expects_exception?; true; end

    def evaluate(actual_exception, expected_class, expected_message=nil)
      actual_message = actual_exception && actual_exception.message
      if actual_exception.nil?
        fail("should have raised #{expected_class}, but raised nothing")
      elsif expected_class != actual_exception.class
        fail("should have raised #{expected_class}, not #{actual_exception.class}")
      elsif expected_message && !(actual_message.to_s =~ %r[#{expected_message}])
        fail("expected #{expected_message.inspect} for message, not #{actual_message.inspect}")
      else
        pass
      end
    end
  end
  
  Assertion.register_macro :raises, RaisesMacro
end

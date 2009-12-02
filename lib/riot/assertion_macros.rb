module Riot
  class Assertion
    # Asserts that the result of the test equals the expected value. Using the +===+ operator to assert
    # equality.
    #   asserts("test") { "foo" }.equals("foo")
    #   should("test") { "foo" }.equals("foo")
    #   asserts("test") { "foo" }.equals { "foo" }
    assertion(:equals) do |actual, expected|
      expected === actual ? pass : fail("expected #{expected.inspect}, not #{actual.inspect}")
    end

    # Asserts that the result of the test is nil
    #   asserts("test") { nil }.nil
    #   should("test") { nil }.nil
    assertion(:nil) do |actual|
      actual.nil? ? pass : fail("expected nil, not #{actual.inspect}")
    end

    # Asserts that the result of the test is a non-nil value. This is useful in the case where you don't want
    # to translate the result of the test into a boolean value
    #   asserts("test") { "foo" }.exists
    #   should("test") { 123 }.exists
    #   asserts("test") { "" }.exists
    #   asserts("test") { nil }.exists # This would fail
    assertion(:exists) do |actual|
      !actual.nil? ? pass : fail("expected a non-nil value")
    end

    # Asserts that the result of the test is an object that is a kind of the expected type
    #   asserts("test") { "foo" }.kind_of(String)
    #   should("test") { "foo" }.kind_of(String)
    assertion(:kind_of) do |actual, expected|
      actual.kind_of?(expected) ? pass : fail("expected kind of #{expected}, not #{actual.class.inspect}")
    end

    # Asserts that an instance variable is defined for the result of the assertion. Value of instance
    # variable is expected to not be nil
    #   setup { User.new(:email => "foo@bar.baz") }
    #   topic.assigns(:email)
    #
    # If a value is provided in addition to the variable name, the actual value of the instance variable
    # must equal the expected value
    #   setup { User.new(:email => "foo@bar.baz") }
    #   topic.assigns(:email, "foo@bar.baz")
    assertion(:assigns) do |actual, *expectings|
      variable, expected_value = expectings
      variable_name            = "@#{variable}"
      actual_value             = actual.instance_variable_defined?(variable_name) ? actual.instance_variable_get(variable_name) : nil
      if actual_value.nil?
        fail("expected @#{variable} to be assigned a value")
      elsif !expected_value.nil? && expected_value != actual_value
        fail(%Q[expected @#{variable} to be equal to #{expected_value.inspect}, not #{actual_value.inspect}])
      else
        pass
      end
    end

    # Asserts that the result of the test equals matches against the proved expression
    #   asserts("test") { "12345" }.matches(/\d+/)
    #   should("test") { "12345" }.matches(/\d+/)
    assertion(:matches) do |actual, expected|
      expected = %r[#{Regexp.escape(expected)}] if expected.kind_of?(String)
      actual =~ expected ? pass : fail("expected #{expected.inspect} to match #{actual.inspect}")
    end

    # Asserts that the result of the test is an object that responds to the given method
    #   asserts("test") { "foo" }.respond_to(:to_s)
    #   should("test") { "foo" }.respond_to(:to_s)
    assertion(:respond_to) do |actual, expected|
      actual.respond_to?(expected) ? pass : fail("expected method #{expected.inspect} is not defined")
    end

    # Asserts that two arrays contain the same elements, the same number of times.
    #   asserts("test") { ["foo", "bar"] }.same_elements(["bar", "foo"])
    #   should("test") { ["foo", "bar"] }.same_elements(["bar", "foo"])
    assertion(:same_elements) do |actual, expected|
      require 'set'
      same = (Set.new(expected) == Set.new(actual))
      same ? pass : fail("expected elements #{expected.inspect} to match #{actual.inspect}")
    end

    # Asserts that the test raises the expected Exception
    #   asserts("test") { raise My::Exception }.raises(My::Exception)
    #   should("test") { raise My::Exception }.raises(My::Exception)
    #
    # You can also check to see if the provided message equals or matches your expectations. The message
    # from the actual raised exception will be converted to a string before any comparison is executed.
    #   asserts("test") { raise My::Exception, "Foo" }.raises(My::Exception, "Foo")
    #   asserts("test") { raise My::Exception, "Foo Bar" }.raises(My::Exception, /Bar/)
    assertion(:raises, expect_exception=true) do |actual_exception, expected_class, expected_message|
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

    # Asserts the result is empty
    #   asserts("a string") { "" }.empty
    #   asserts("an array") { [] }.empty
    #   asserts("a hash") { Hash.new }.empty
    assertion(:empty) do |actual|
      actual.length == 0 ? pass : fail("expected #{actual.inspect} to be empty")
    end

    # Asserts the result has items
    #   asserts("an array") { [1] }.any
    #   asserts("a hash") { {:name => 'washington'} }.any
    assertion(:any) do |actual|
      actual.any? ? pass : fail("expected #{actual.inspect} to have items")
    end

    # Asserts the result contains the expected element
    #   asserts("a string") { "world" }.includes('o')
    #   asserts("an array") { [1,2,3] }.includes(2)
    #   asserts("a range") { (1..15) }.includes(10)
    assertion(:includes) do |actual, expected|
      actual.include?(expected) ? pass : fail("expected #{actual.inspect} to include #{expected.inspect}")
    end

  end # Assertion
end # Riot

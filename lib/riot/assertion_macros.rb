module Riot
  class Assertion
    # Asserts that the result of the test equals the expected value
    #   asserts("test") { "foo" }.equals("foo")
    #   should("test") { "foo" }.equals("foo")
    assertion(:equals) do |actual, expected|
      expected == actual ? pass : fail("expected #{actual.inspect} to equal #{expected.inspect}")
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
      actual.kind_of?(expected) ? pass : fail("expected kind of #{expected}, not #{actual.inspect}")
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
      actual_value = actual.instance_variable_get("@#{variable}")
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

  end # Assertion
end # Riot

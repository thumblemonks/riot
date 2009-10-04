module Riot
  module AssertionMacros
    # Asserts that the result of the test equals the expected value
    #   asserts("test") { "foo" }.equals("foo")
    #   should("test") { "foo" }.equals("foo")
    def equals(expected)
      expected == actual || fail("expected #{expected.inspect}, not #{actual.inspect}")
    end

    # Asserts that the result of the test is nil
    #   asserts("test") { nil }.nil
    #   should("test") { nil }.nil
    def nil
      actual.nil? || fail("expected nil, not #{actual.inspect}")
    end

    # Asserts that the test raises the expected Exception
    #   asserts("test") { raise My::Exception }.raises(My::Exception)
    #   should("test") { raise My::Exception }.raises(My::Exception)
    #   asserts("test") { raise My::Exception, "Foo" }.raises(My::Exception, "Foo")
    #   asserts("test") { raise My::Exception, "Foo Bar" }.raises(My::Exception, /Bar/)
    def raises(expected, expected_message=nil)
      actual_error = raised
      @raised = nil
      return fail("should have raised #{expected}, but raised nothing") unless actual_error
      return fail("should have raised #{expected}, not #{error.class}") unless expected == actual_error.class
      if expected_message && !(actual_error.message =~ %r[#{expected_message}])
        return fail("expected #{expected_message} for message, not #{actual_error.message}")
      end
      true
    end

    # Asserts that the result of the test equals matches against the proved expression
    #   asserts("test") { "12345" }.matches(/\d+/)
    #   should("test") { "12345" }.matches(/\d+/)
    def matches(expected)
      expected = %r[#{Regexp.escape(expected)}] if expected.kind_of?(String)
      actual =~ expected || fail("expected #{expected.inspect} to match #{actual.inspect}")
    end

    # Asserts that the result of the test is an object that is a kind of the expected type
    #   asserts("test") { "foo" }.kind_of(String)
    #   should("test") { "foo" }.kind_of(String)
    def kind_of(expected)
      actual.kind_of?(expected) || fail("expected kind of #{expected}, not #{actual.inspect}")
    end
  end # AssertionMacros
end # Riot

Riot::Assertion.instance_eval { include Riot::AssertionMacros }
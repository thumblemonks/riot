module Protest
  module AssertionMacros
    # Asserts that the result of the test equals the expected value
    #   asserts("test") { "foo" }.equals("foo")
    def equals(expected)
      expected == actual || failure("expected #{expected.inspect}, not #{actual.inspect}")
    end

    # Asserts that the result of the test is nil
    #   asserts("test") { nil }.nil
    def nil
      actual.nil? || failure("expected nil, not #{actual.inspect}")
    end

    # Asserts that the test raises the expected Exception
    #   asserts("test") { raise My::Exception }.raises(My::Exception)
    def raises(expected)
      failure("should have raised #{expected}, but raised nothing") unless raised
      failure("should have raised #{expected}, not #{error.class}") unless expected == raised.class
      @raised = nil
    end

    # Asserts that the result of the test equals matches against the proved expression
    #   asserts("test") { "12345" }.matches(/\d+/)
    def matches(expected)
      expected = %r[#{Regexp.escape(expected)}] if expected.kind_of?(String)
      actual =~ expected || failure("expected #{expected.inspect} to match #{actual.inspect}")
    end

    # Asserts that the result of the test is an object that is a kind of the expected type
    #   asserts("test") { "foo" }.kind_of(String)
    def kind_of(expected)
      actual.kind_of?(expected) || failure("expected kind of #{expected}, not #{actual.inspect}")
    end
  end # AssertionMacros
end # Protest

Protest::Assertion.instance_eval { include Protest::AssertionMacros }
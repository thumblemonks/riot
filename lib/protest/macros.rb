module Protest
  module AssertionMacros
    # Asserts that the result of the test equals the expected value
    #   asserts("test").equals("foo") { "foo" }
    def equals(expected, &block)
      assert_block do |scope|
        actual = scope.instance_eval(&block)
        expected == actual || failure("expected #{expected.inspect}, not #{actual.inspect}")
      end
    end
    
    # Asserts that the result of the test is nil
    #   asserts("test").nil { nil }
    def nil(&block)
      equals(nil, &block)
    end

    # Asserts that the test raises the expected Exception
    #   asserts("test").raises(My::Exception) { raise My::Exception }
    def raises(expected, &block)
      assert_block do |scope|
        begin
          scope.instance_eval(&block)
        rescue Exception => e
          failure("should have raised #{expected}, not #{e.class}") unless expected == e.class
        else
          failure("should have raised #{expected}, but raised nothing")
        end
      end
    end
    
    # Asserts that the result of the test equals matches against the proved expression
    #   asserts("test").matches(/\d+/) { "12345" }
    def matches(expected, &block)
      expected = %r[#{Regexp.escape(expected)}] if expected.kind_of?(String)
      assert_block do |scope|
        actual = scope.instance_eval(&block)
        actual =~ expected || failure("expected #{expected.inspect} to match #{actual.inspect}")
      end
    end

    # Asserts that the result of the test is an object that is a kind of the expected type
    #   asserts("test").kind_of(String) { "foo" }
    def kind_of(expected, &block)
      assert_block do |scope|
        actual = scope.instance_eval(&block)
        actual.kind_of?(expected) || failure("expected kind of #{expected}, not #{actual.inspect}")
      end
    end
  end # AssertionMacros
end # Protest

Protest::Assertion.instance_eval { include Protest::AssertionMacros }
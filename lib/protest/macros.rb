module Protest
  module AssertionMacros
    def equals(expected, &block)
      assert_block do |scope|
        actual = scope.instance_eval(&block)
        expected == actual || failure("expected #{expected.inspect}, not #{actual.inspect}")
      end
    end
    
    def nil(&block)
      equals(nil, &block)
    end

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
    
    def matches(expected, &block)
      expected = %r[#{Regexp.escape(expected)}] if expected.kind_of?(String)
      assert_block do |scope|
        actual = scope.instance_eval(&block)
        actual =~ expected || failure("expected #{expected.inspect} to match #{actual.inspect}")
      end
    end

    def kind_of(expected, &block)
      assert_block do |scope|
        actual = scope.instance_eval(&block)
        actual.kind_of?(expected) || failure("expected kind of #{expected}, not #{actual.inspect}")
      end
    end
  end # AssertionMacros
end # Protest

Protest::Assertion.instance_eval { include Protest::AssertionMacros }
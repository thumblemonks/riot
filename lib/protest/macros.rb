module Protest
  module ContextMacros
    def denies(description, &block)
      asserts(description, &block).not
    end
  end # ContextMacros

  module AssertionMacros
    def nil(&block)
      equals(nil, &block)
    end
  end # ContextMacros
end # Protest

Protest::Context.instance_eval { include Protest::ContextMacros }
Protest::Assertion.instance_eval { include Protest::AssertionMacros }
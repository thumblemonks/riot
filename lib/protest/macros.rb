module Protest
  module ContextMacros
    def denies(description, &block)
      asserts(description, &block).not
    end
  end # ContextMacros
end # Protest

Protest::Context.instance_eval { include Protest::ContextMacros }
module Riot
  module RR

    module ContextHelpers
    private
      def assertion_class; Riot::RR::Assertion; end
      def situation_class; Riot::RR::Situation; end
    end # ContextHelpers

    def self.enable(context_class)
      context_class.instance_eval { include Riot::RR::ContextHelpers }
    end

  end # RR
end # Riot

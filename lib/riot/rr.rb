require 'rr'

module Riot
  module RR

    class Situation < Riot::Situation
      include ::RR::Adapters::RRMethods
    end # Situation

    class Assertion < Riot::Assertion
      def run(situation)
        result = super
        situation.verify
        result
      rescue ::RR::Errors::RRError => e
        [:fail, e.message.gsub(/\n/, " ")]
      ensure
        situation.reset
      end
    end # Assertion

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

Riot::RR.enable(Riot::Context)

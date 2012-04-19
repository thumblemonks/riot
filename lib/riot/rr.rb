require 'rr'

module Riot
  # Enables inherent RR support in Riot. When required in, all contexts and assertions are adapted to have
  # RR support.
  module RR

    # Basically, provides a {Riot::Situation} that has been adapted to RR. This means that any of the
    # RR methods that would typically be used: +mock+, +stub+, +verify+, etc. will be available to any
    # setup, yeardown, helper, hookup, or assertion.
    class Situation < Riot::Situation
      include ::RR::Adapters::RRMethods

      def initialize
        self.reset
        super
      end
    end # Situation

    # Binds the {Riot::Assertion} to RR so that successes and failures found by RR are inherently handled
    # during an assertion evaluation. In effect, if RR suggests failure during validation, the assertion
    # will fail and report these failures.
    class Assertion < Riot::Assertion
      # Adds RR support to {Riot::Assertion#run}. The basic flow is to:
      # * run the test as normal
      # * ask RR to verify mock results
      # * report any errors or return the result of the assertion as normal
      # * reset RR so that the next assertion in the context can be verified cleanly.
      #
      # @param (see Riot::Assertion#run)
      # @return (see Riot::Assertion#run)
      def run(situation)
        result = super
        situation.verify
        result
      rescue ::RR::Errors::RRError => e
        result.first == :pass ? [:fail, e.message.gsub(/\n/, " ")] : result
      ensure
        situation.reset
      end
    end # Assertion

    # Redefines the classes {Riot::Context} will use when creating new assertions and situations to be the
    # ones provided RR support. See {Riot::RR::Assertion} and {Riot::RR::Situation}.
    module ContextClassOverrides
      # (see Riot::ContextClassOverrides#assertion_class)
      def assertion_class; Riot::RR::Assertion; end

      # (see Riot::ContextClassOverrides#situation_class)
      def situation_class; Riot::RR::Situation; end
    end # ContextClassOverrides

    # A convenience method for telling {Riot::RR::ContextClassOverrides} to mix itself into {Riot::Context}.
    # Thus, enabling RR support in Riot.
    #
    # @param [Class] context_class the class representing the Context to bind to
    def self.enable(context_class)
      context_class.instance_eval { include Riot::RR::ContextClassOverrides }
    end

  end # RR
end # Riot

Riot::RR.enable(Riot::Context)

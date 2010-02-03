module Riot
  module RR
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
  end # RR
end # Riot

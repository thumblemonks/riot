module Riot
  module RR
    class Situation < Riot::Situation
      include ::RR::Adapters::RRMethods
      def initialize
        @setups = []
      end

      def setup(&block)
        @setups << lambda { super(&block) }
      end

      # We are re-running setup each time :(
      def evaluate(&block)
        @setups.each { |setup_block| setup_block.call  }
        super(&block)
      end
    end # Situation
  end # RR
end # Riot
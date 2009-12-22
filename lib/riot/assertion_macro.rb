module Riot
  class AssertionMacro
    def self.default; @default_macro ||= new; end

    def pass() [:pass]; end
    def fail(message) [:fail, message]; end
    def error(e) [:error, e]; end

    def expects_exception?; false; end

    def evaluate(actual)
      actual ? pass : fail("Expected non-false but got #{actual.inspect} instead")
    end
  end
end

require 'riot/assertion_macros/any'
require 'riot/assertion_macros/assigns'
require 'riot/assertion_macros/empty'
require 'riot/assertion_macros/equals'
require 'riot/assertion_macros/exists'
require 'riot/assertion_macros/includes'
require 'riot/assertion_macros/kind_of'
require 'riot/assertion_macros/matches'
require 'riot/assertion_macros/nil'
require 'riot/assertion_macros/raises'
require 'riot/assertion_macros/respond_to'
require 'riot/assertion_macros/same_elements'
require 'riot/assertion_macros/size'

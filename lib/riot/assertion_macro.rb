require 'riot/message'

module Riot
  # The base class for all assertion macros.
  #
  # == Using macros
  #
  # Macros are applied to the return value of assertions. For example, the
  # +empty+ macro asserts that the value is empty or denies that it is empty e.g.
  #
  #     asserts(:comments).empty?
  #     denies(:comments).empty?
  #
  # == Writing your own macros
  #
  # Macros are added by subclassing {AssertionMacro}. For example, here's
  # the implementation of +empty+:
  #
  #     class EmptyMacro < AssertionMacro
  #       register :empty
  #
  #       def evaluate(actual)
  #         actual.length == 0 ? pass : fail(expected_message(actual).to_be_empty)
  #       end
  #
  #       def devaluate(actual)
  #         actual.empty? ? fail(expected_message(actual).to_not_be_empty) : pass(new_message.is_empty)
  #       end
  #     end
  #
  class AssertionMacro
    class << self
      # Whether the macro expects an exception to be thrown.
      #
      # @return [Boolean]
      attr_reader :expects_exception

      # @private
      # The default macro.
      #
      # @return [Riot::AssertionMacro]
      def default
        @default_macro ||= new
      end

      # Specify that the macro expects an exception to be thrown by the assertion.
      def expects_exception!
        @expects_exception = true
      end

      # Register the macro under the given name.
      #
      # @param [String, Symbol] name the name of the macro
      def register(name)
        Assertion.register_macro name, self
      end
    end

    # During failure reporting, what line number did the failure occur at
    # @return [Number]
    attr_accessor :line

    # During failure reporting, what file did the failure occur in
    # @return [String]
    attr_accessor :file

    # Returns a status tuple indicating the assertion passed.
    #
    # @param [String] message the message to report with
    # @return [Array[Symbol, String]]
    def pass(message=nil) [:pass, message.to_s]; end

    # Returns a status tuple indicating the assertion failed and where it failed it if that can be
    # determined.
    #
    # @param [String] message the message to report with
    # @return [Array[Symbol, String, Number, String]]
    def fail(message) [:fail, message.to_s, line, file]; end

    # Returns a status tuple indicating the assertion had an unexpected error.
    #
    # @param [Exception] ex the Exception that was captured
    # @return [Array[Symbol, Exception]]
    def error(ex) [:error, ex]; end

    # Returns +true+ if this macro expects to handle Exceptions during evaluation.
    #
    # @return [boolean]
    def expects_exception?; self.class.expects_exception; end

    # Supports positive assertion testing. This is where magic happens.
    #
    # @param [Object] actual the value returned from evaling the {Riot::Assertion Assertion} block
    # @return [Array] response from either {#pass}, {#fail} or {#error}
    def evaluate(actual)
      actual ? pass : fail("Expected non-false but got #{actual.inspect} instead")
    end

    # Supports negative/converse assertion testing. This is also where magic happens.
    #
    # @param [Object] actual the value returned from evaling the {Riot::Assertion Assertion} block
    # @return [Array] response from either {#pass}, {#fail} or {#error}
    def devaluate(actual)
      !actual ? pass : fail("Expected non-true but got #{actual.inspect} instead")
    end

    # Creates a new message for use in any macro response that is initially empty.
    #
    # @param [Array<Object>] *phrases array of object whose values will be inspected and added to message
    # @return [Riot::Message]
    def new_message(*phrases) Message.new(*phrases); end

    # Creates a new message for use in any macro response that will start as "should have ".
    #
    # @param [Array<Object>] *phrases array of object whose values will be inspected and added to message
    # @return [Riot::Message]
    def should_have_message(*phrases) new_message.should_have(*phrases); end

    # Creates a new message for use in any macro response that will start as "expected ".
    #
    # @param [Array<Object>] *phrases array of object whose values will be inspected and added to message
    # @return [Riot::Message]
    def expected_message(*phrases) new_message.expected(*phrases); end
  end
end

require 'riot/assertion_macros/any'
require 'riot/assertion_macros/assigns'
require 'riot/assertion_macros/empty'
require 'riot/assertion_macros/equals'
require 'riot/assertion_macros/equivalent_to'
require 'riot/assertion_macros/exists'
require 'riot/assertion_macros/includes'
require 'riot/assertion_macros/kind_of'
require 'riot/assertion_macros/matches'
require 'riot/assertion_macros/nil'
require 'riot/assertion_macros/raises'
require 'riot/assertion_macros/raises_kind_of'
require 'riot/assertion_macros/respond_to'
require 'riot/assertion_macros/same_elements'
require 'riot/assertion_macros/size'

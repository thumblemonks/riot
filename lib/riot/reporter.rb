module Riot

  # A Reporter decides how to output the result of a test. When a context is set to be executed, the
  # {Riot::Reporter#describe_context} method is called with the context that will be running; this remains
  # so until the next context is executed. After each {Riot::AssertionMacro#evaluate assertion is evaluated}, 
  # {Riot::Reporter#report} is called with the description of the assertion and the resulting response.
  #
  # The general idea is that a sub-class of Reporter should be defined that knows specifically how to
  # output the reported results. In the sub-class, you simply need to implement a +pass+, +fail+, +error+,
  # and +results+ method.
  class Reporter
    # Count of successful assertions so far
    attr_accessor :passes

    # Count of failed assertions so far
    attr_accessor :failures

    # Count of errored assertions so far
    attr_accessor :errors

    # The context that is currently being reported on
    attr_accessor :current_context

    # Creates a new Reporter instance and initializes counts to zero
    def initialize(*args)
      @options = args.extract_options!
      @passes = @failures = @errors = 0
      @current_context = Riot::RootContext.new
    end

    def new(*args, &block); self; end

    # Returns true if no failures or errors have been produced yet.
    #
    # @return [Boolean]
    def success?
      (@failures + @errors) == 0
    end

    # Starts a timer, execute the provided block, then reports the results. Useful for timing context
    # execution(s).
    #
    # @param [lambda] &block the contexts to run
    def summarize(&block)
      started = Time.now
      yield
    ensure
      results(Time.now - started)
    end

    # Called when a new context is about to execute to set the state for this Reporter instance.
    #
    # @param [Riot::Context] context the context that is about to execute
    def describe_context(context)
      @current_context = context
    end

    # Called immediately after an assertion has been evaluated. From this method either +pass+, +fail+,
    # or +error+ will be called.
    #
    # @param [String] description the description of the assertion
    # @param [Array<Symbol, *[Object]>] response the evaluation response from the assertion
    def report(description, response)
      code, result = *response
      case code
      when :pass then
        @passes += 1
        pass(description, result)
      when :fail then
        @failures += 1
        message, line, file = *response[1..-1]
        fail(description, message, line, file)
      when :error, :setup_error, :context_error then
        @errors += 1
        error(description, result)
      end
    end

    # Called if the assertion passed.
    #
    # @param [String] description the description of the assertion
    # @param [Array<Symbol, String]>] result the evaluation response from the assertion
    def pass(description, result)
      raise "Implement this in a sub-class"
    end

    # Called if the assertion failed.
    #
    # @param [String] description the description of the assertion
    # @param [Array<Symbol, String, Number, String]>] response the evaluation response from the assertion
    def fail(description, message, line, file)
      raise "Implement this in a sub-class"
    end

    # Called if the assertion had an unexpected error.
    #
    # @param [String] description the description of the assertion
    # @param [Array<Symbol, Exception]>] result the exception from the assertion
    def error(description, result)
      raise "Implement this in a sub-class"
    end

    # Called after all contexts have finished. This is where the final results can be output.
    #
    # @param [Number] time_taken number of seconds taken to run everything
    def results(time_taken)
      raise "Implement this in a sub-class"
    end
  end # Reporter

end # Riot

require 'riot/reporter/silent'
require 'riot/reporter/io'
require 'riot/reporter/story'
require 'riot/reporter/dot_matrix'
require 'riot/reporter/pretty_dot_matrix'

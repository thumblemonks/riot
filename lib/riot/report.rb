require 'stringio'

module Riot
  class Report
    attr_reader :bad_results, :passes, :failures, :errors, :time_taken
    def initialize
      @bad_results = []
      @passes, @failures, @errors, @time_taken = 0, 0, 0, 0.0
    end

    def passed?; failures + errors == 0; end
    def assertions; passes + failures + errors; end

    def time(&block)
      @start = Time.now
      yield
      @time_taken += (Time.now - @start).to_f
    end

    def process_assertion(assertion)
      if assertion.passed?
        passed
      else
        send((assertion.errored? ? :errored : :failed), assertion.result)
      end
    end

    def passed; @passes += 1; end
    
    def failed(failure)
      @failures += 1
      @bad_results << failure
    end

    def errored(error)
      @errors += 1
      @bad_results << error
    end
  end # Report

  class NilReport < Report
    def results; end
    def time(&block); yield; end
  end # NilReport

  class TextReport < Report
    def initialize(writer=nil)
      super()
      @writer ||= STDOUT
    end

    def passed
      super && @writer.print('.')
    end

    def failed(failure)
      super && @writer.print('F')
    end

    def errored(error)
      super && @writer.print('E')
    end

    def results
      @writer.puts "\n\n"
      print_result_stack
      format = "%d assertions, %d failures, %d errors in %s seconds"
      @writer.puts format % [assertions, failures, errors, ("%0.6f" % time_taken)]
    end
  private
    def print_result_stack
      bad_results.each_with_index do |result, idx|
        @writer.puts render_result(idx + 1, result)
        @writer.puts "  " + result.backtrace.join("\n  ") if result.print_stacktrace?
        @writer.puts "\n\n"
      end
    end

    def render_result(idx, result) "#%d - %s" % [idx, result.to_s]; end
  end # TextReport
end # Riot

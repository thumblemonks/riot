module Protest
  class Report
    attr_reader :bad_results, :passes, :failures, :errors
    def initialize
      @bad_results = []
      @passes, @failures, @errors = 0, 0 ,0
    end

    def passed?; failures + errors == 0; end
    def assertions; passes + failures + errors; end

    def start; @start = Time.now; end
    def stop; @stop = Time.now; end
    def time_taken; @stop - @start; end
    
    def record(context, object)
      case object
      when Protest::Error then
        @bad_results << [context, object]
        @errors += 1
        errored
      when Protest::Failure then
        @bad_results << [context, object]
        @failures += 1
        failed
      else
        @passes += 1
        passed
      end
    end
  end # Report

  class TextReport < Report
    def initialize(writer=nil)
      super()
      @writer ||= STDOUT
    end

    def passed; @writer.print('.'); end
    def failed; @writer.print('F'); end
    def errored; @writer.print('E'); end

    def results
      @writer.puts "\n\n"
      print_result_stack
      format = "%d assertions, %d failures, %d errors in %s seconds"
      @writer.puts format % [assertions, failures, errors, ("%0.6f" % time_taken)]
    end
  private
    def print_result_stack
      bad_results.each_with_index do |recorded, idx|
        ctx, failure = recorded
        @writer.puts "#%d - %s asserts %s: %s" % [idx + 1, ctx.to_s, failure.assertion.to_s, failure.to_s]
        @writer.puts "  " + failure.backtrace.join("\n  ") + "\n\n"
      end
    end
  end

  class NilReport < Report
    def passed; end
    def failed; end
    def errored; end
    def results; end
  end
end # Protest

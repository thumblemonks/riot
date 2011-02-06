module Riot

  # Outputs in the dot-notion almost everyone should be familiar with, "." implies pass, "F" implues a
  # failure, and "E" implies an error. If ansi-coloring is available, it is used. Error and failure messages
  # are buffered for output until the end.
  class DotMatrixReporter < IOReporter
    # Creates a new DotMatrixReporter and initializes the failure/error details buffer.
    # @param (see Riot::IOReporter#initialize)
    def initialize(writer=STDOUT)
      super
      @details = []
    end

    # Prints a ".". Prints in green if possible.
    #
    # @param (see Riot::Reporter#pass)
    def pass(description, message)
      print green(".")
    end

    # Prints a "F" and saves the failure details (including line number and file) for the end.
    # Prints in yellow if possible.
    #
    # @param (see Riot::Reporter#fail)
    def fail(description, message, line, file)
      print yellow("F")
      @details << "FAILURE - #{test_detail(description, message)} #{line_info(line, file)}".strip
    end

    # Prints a "E" and saves the error details (including backtrace) for the end. Prints in red if possible.
    #
    # @param (see Riot::Reporter#error)
    def error(description, e)
      print red("E")
      @details << "ERROR - #{test_detail(description, format_error(e))}"
    end

    # (see Riot::Reporter#results)
    def results(time_taken)
      puts "\n#{@details.join("\n\n")}" unless @details.empty?
      super
    end
  private
    def test_detail(description, message)
      "#{current_context.detailed_description} #{description} => #{message}"
    end
  end # DotMatrixReporter

end # Riot

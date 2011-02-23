module Riot

  # This is essentially just DotMatrix with the legacy DotMatrix formatting, slightly better.
  # Failure and Error outputs are color labeled and are formatted neatly and 
  # concisely under each associated label.
  # example:
  # ........FE....
  # FAILURE
  #  A failure would have a message like this => expected 1, not 0
  #  (on line 26 in test/core/blah.rb)
  # ERROR
  #  A reporter asserts this errors => Exception occured
  #  at test/core/report_test.rb:24:in `block (2 levels) in <top (required)>'
  #
  class PrettyDotMatrixReporter < DotMatrixReporter

    # Prints a yellow F and formats the Fail messages a bit better
    # than the default DotMatrixReporter
    def fail(description, message, line, file)
      print yellow('F')
      @details << "#{yellow("FAILURE")}\n #{test_detail(description, message)}\n #{line_info(line, file)}".strip
    end

    # Prints out an red E and formats the fail message better
    def error(description, e)
      print red('E')
      @details << "#{red("ERROR")}\n #{test_detail(description,"#{e} occured")}\n #{simple_error(e)}"
    end

    def simple_error(e)
      format = []
      filter_backtrace(e.backtrace) { |line| format << "at #{line}" }

      format.join("\n")
    end
  end
end


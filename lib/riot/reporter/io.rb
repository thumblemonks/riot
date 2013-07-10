module Riot

  # An IOReporter is one that expects to use an IO object to output results to. Thus, whatever is available
  # by an instance of an IO object should be available to whatever is given to this reporter to use.
  #
  # This is an abstract class. You should use some other or define your own sub-class that knows how to
  # handle +pass+, +fail+, and +error+.
  class IOReporter < Reporter

    # Creates a new IOReporter. You can give it your own IO writer or it will default to +STDOUT+.
    # If you want to specifically turn colorization off in the output, pass the +plain+ option.
    #
    # @param [IO] writer the writer to use for results
    # @param [Hash] options options for reporter
    def initialize(*args)
      super
      @options = args.extract_options!
      @writer = (args.shift || STDOUT)
    end

    # (see Riot::Reporter#results)
    def results(time_taken)
      values = [passes, failures, errors, ("%0.6f" % time_taken)]
      puts "\n%d passes, %d failures, %d errors in %s seconds" % values
    end

  protected
    # Helper that knows how to write output to the writer with a newline.
    #
    # @param [String] message the message to be printed
    def puts(message) @writer.puts(message); end

    # Helper that knows how to write output to the writer without a newline.
    #
    # @param [String] message the message to be printed
    def print(message) @writer.print(message); end

    # Takes a line number, the file it corresponds to, and generates a formatted string for use in failure
    # responses.
    #
    # @param [Number] line the line number of the failure
    # @param [String] file the name of the file the failure was in
    # @return [String] formatted failure line
    def line_info(line, file)
      line ? "(on line #{line} in #{file})" : ""
    end

    # Generates a message for assertions that error out. However, in the additional stacktrace, any mentions
    # of Riot and Rake framework methods calls are removed. Makes for a more readable error response.
    #
    # @param [Exception] e the exception to generate the backtrace from
    # @return [String] the error response message
    def format_error(e)
      format = ["    #{e.class.name} occurred", "#{e.to_s}"]
      filter_backtrace(e.backtrace) { |line| format << "      at #{line}" }
      format.join("\n")
    end

    # Filters Riot and Rake method calls from an exception backtrace.
    #
    # @param [Array] backtrace an exception's backtrace
    # @param [lambda] &line_handler called each time a good line is found
    def filter_backtrace(backtrace, &line_handler)
      backtrace.reverse_each do |bt|
        yield bt unless (bt =~ /(\/lib\/riot|rake_test_loader)/)
      end
    end

    # Color output
    def red(str);    with_color(31, str); end
    def yellow(str); with_color(33, str); end
    def green(str);  with_color(32, str); end

    def plain?
      (@options[:plain] || @options["plain"])
    end

    # for color reference:
    # http://www.pixelbeat.org/docs/terminal_colours/
    def with_color(code,str)
      plain? ? str : "\e[#{code}m#{str}\e[0m"
    end
  end # IOReporter

end # Riot

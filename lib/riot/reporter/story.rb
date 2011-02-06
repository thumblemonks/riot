module Riot

  # For each context that is started and assertion that is run, its description is printed to the console
  # on its own line. Regarding assertions, if ansi-colors are available then passing assertions are printed
  # in green, failing in yellow, and errors in red. Note that backtraces are not reported for errors; see
  # {Riot::VerboseStoryReporter}.
  class StoryReporter < IOReporter
    # Prints the descrition of the context on its own line
    #
    # @param (see Riot::Reporter#describe_context)
    def describe_context(context)
      super
      puts context.detailed_description
    end

    # Prints the description of the assertion. Prints in green if possible.
    #
    # @param (see Riot::Reporter#pass)
    def pass(description, message)
      puts "  + " + green("#{description} #{message}".strip)
    end

    # Prints the description of the assertion and the line number of the failure. Prints in yellow if
    # possible.
    #
    # @param (see Riot::Reporter#fail)
    def fail(description, message, line, file)
      puts "  - " + yellow("#{description}: #{message} #{line_info(line, file)}".strip)
    end

    # Prints the description of the assertion and the exception message. Prints in red if
    # possible.
    #
    # @param (see Riot::Reporter#error)
    def error(description, e)
      puts "  ! " + red("#{description}: #{e.message}")
    end
  end # StoryReporter

  # Same as {Riot::StoryReporter} except that backtraces are printed for assertions with errors
  class VerboseStoryReporter < StoryReporter
    # Prints the description of the assertion and the exception backtrace. Prints in red if
    # possible.
    #
    # @param (see Riot::Reporter#error)
    def error(description, e)
      super
      puts red(format_error(e))
    end
  end # VerboseStoryReporter

end # Riot

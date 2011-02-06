module Riot

  # Basically, the Null Object pattern; nothing is output from this reporter.
  class SilentReporter < Reporter
    # (see Riot::Reporter#pass)
    def pass(description, message); end

    # (see Riot::Reporter#fail)
    def fail(description, message, line, file); end

    # (see Riot::Reporter#error)
    def error(description, e); end

    # (see Riot::Reporter#results)
    def results(time_taken); end
  end # SilentReporter

end # Riot

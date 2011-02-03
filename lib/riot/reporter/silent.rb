module Riot

  class SilentReporter < Reporter
    def pass(description, message); end
    def fail(description, message, line, file); end
    def error(description, e); end
    def results(time_taken); end
  end # SilentReporter

end # Riot

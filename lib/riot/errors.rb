module Riot
  class Failure < Exception
    def print_stacktrace?; false; end
  end

  class Error < Failure
    attr_reader :original_exception
    def initialize(message, raised)
      super(message)
      set_backtrace(raised.backtrace)
      @original_exception = raised
    end
    def print_stacktrace?; true; end
  end
end # Riot

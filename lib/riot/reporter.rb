module Riot
  class Reporter
    attr_accessor :passes, :failures, :errors
    def initialize
      @passes = @failures = @errors = 0
    end

    def summarize(&block)
      started = Time.now
      yield
    ensure
      results(Time.now - started)
    end

    def describe_context(msg); end

    def report(description, response)
      code, result = *response
      case code
      when :pass then
        @passes += 1
        pass(description)
      when :fail then
        @failures += 1
        fail(description, result)
      when :error then
        @errors += 1
        error(description, result)
      end
    end
  end # Reporter

  class IOReporter < Reporter
    def initialize(writer=nil)
      super()
      @writer = writer || STDOUT
    end
    def say(message) @writer.puts(message); end

    def results(time_taken)
      values = [@passes, @failures, @errors, ("%0.6f" % time_taken)]
      say "\n%d passes, %d failures, %d errors in %s seconds" % values
    end
  end

  class StoryReporter < IOReporter
    def describe_context(description) say description; end
    def pass(description) say "  + " + description.green; end
    def fail(description, message) say "  - " + "#{description}: #{message}".yellow; end
    def error(description, e) say "  ! " + "#{description}: #{e.message}".red; end
  end

  class VerboseReporter < StoryReporter
    def error(description, e)
      super(description, e)
      say "    #{e.class.name} occured".red
      e.backtrace.each { |line| say "      at #{line}".red }
    end
  end

  class DotMatrixReporter < IOReporter
    def pass(description); @writer.write ".".green; end
    def fail(description, message); @writer.write "F".yellow; end
    def error(description, e); @writer.write "E".red; end
    # TODO: Print the failures and errors at the end. Sorry :|
  end

  class SilentReporter < Reporter
    def pass(description); end
    def fail(description, message); end
    def error(description, e); end
    def results(time_taken); end
  end
end # Riot

begin
  raise LoadError if ENV["TM_MODE"]
  require 'rubygems'
  require 'colorize'
rescue LoadError
  class ::String
    def green; self; end
    alias :red :green
    alias :yellow :green
  end
end

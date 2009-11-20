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

    def start_context(msg); end

    def update(description, response)
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
    def pass(description)
      @writer.print(".")
    end
    def say(message) @writer.puts(message); end
  end

  class StoryReporter < IOReporter
    def start_context(description) say description; end
    def pass(description) say "  + " + description.green; end
    def fail(description, message) say "  - " + "#{description}: #{message}".yellow; end
    def error(description, e) say "  ! " + "#{description}: #{e.message}".red; end
    def results(time_taken) say "\n#{@passes} passes, #{@failures} failures, #{@errors} errors\nFinished in %s seconds" % [("%0.6f" % time_taken)]; end
  end

  class DotMatrixReporter < IOReporter
    def pass(description); @writer.write ".".green; end
    def fail(description, message); @writer.write "F".yellow; end
    def error(description, e); @writer.write "E".red; end
    def results(time_taken) say "\n\nFinished in %s seconds" % [("%0.6f" % time_taken)]; end
  end


  no_colorize = ENV["TM_MODE"] || begin
    require 'rubygems'
    require 'colorize'
  rescue LoadError
    true
  end

  if no_colorize
    class ::String
      def green; self; end
      alias :red :green
      alias :yello :green
    end
  end
end # Riot

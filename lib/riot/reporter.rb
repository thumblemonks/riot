module Riot

  class Reporter
    attr_accessor :passes, :failures, :errors, :current_context

    def initialize
      @passes = @failures = @errors = 0
      @current_context = ""
    end

    def new(*args, &block); self; end

    def success?; (@failures + @errors) == 0; end

    def summarize(&block)
      started = Time.now
      yield
    ensure
      results(Time.now - started)
    end

    def describe_context(context); @current_context = context; end

    def report(description, response)
      code, result = *response
      case code
      when :pass then
        @passes += 1
        pass(description, result)
      when :fail then
        @failures += 1
        message, line, file = *response[1..-1]
        fail(description, message, line, file)
      when :error then
        @errors += 1
        error(description, result)
      end
    end

    def pass(description, result); end
    def fail(description, message, line, file); end
    def error(description, result); end
  end # Reporter

end # Riot

require 'riot/reporter/silent'
require 'riot/reporter/io'
require 'riot/reporter/story'
require 'riot/reporter/dot_matrix'

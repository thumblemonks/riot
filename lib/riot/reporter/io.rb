module Riot

  class IOReporter < Reporter
    def initialize(writer=STDOUT)
      super()
      @writer = writer
    end

    def puts(message) @writer.puts(message); end
    def print(message) @writer.print(message); end

    def line_info(line, file)
      line ? "(on line #{line} in #{file})" : ""
    end

    def results(time_taken)
      values = [passes, failures, errors, ("%0.6f" % time_taken)]
      puts "\n%d passes, %d failures, %d errors in %s seconds" % values
    end

    def format_error(e)
      format = []
      format << "    #{e.class.name} occurred"
      format << "#{e.to_s}"
      filter_backtrace(e.backtrace) { |line| format << "      at #{line}" }

      format.join("\n")
    end

  protected
    def filter_backtrace(backtrace, &line_handler)
      cleansed, bad = [], true

      # goal is to filter all the riot stuff/rake before the first non riot thing
      backtrace.reverse_each do |bt|
        # make sure we are still in the bad part
        bad = (bt =~ /\/lib\/riot/ || bt =~ /rake_test_loader/) if bad
        yield bt unless bad
      end
    end

    begin
      raise LoadError if ENV["TM_MODE"]
      require 'rubygems'
      require 'term/ansicolor'
      include Term::ANSIColor
    rescue LoadError
      def green(str); str; end
      alias :red :green
      alias :yellow :green
    end
  end # IOReporter

end # Riot

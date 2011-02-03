module Riot

  class DotMatrixReporter < IOReporter
    def initialize(writer=STDOUT)
      super
      @details = []
    end

    def pass(description, message)
      print green(".")
    end

    def fail(description, message, line, file)
      print yellow("F")
      @details << "FAILURE - #{test_detail(description, message)} #{line_info(line, file)}".strip
    end

    def error(description, e)
      print red("E")
      @details << "ERROR - #{test_detail(description, format_error(e))}"
    end

    def results(time_taken)
      puts "\n#{@details.join("\n\n")}" unless @details.empty?
      super
    end
  private
    def test_detail(description, message)
      "#{current_context.detailed_description} #{description} => #{message}"
    end
  end # DotMatrixReporter

end # Riot

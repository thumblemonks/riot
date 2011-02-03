module Riot

  class StoryReporter < IOReporter
    def describe_context(context)
      super
      puts context.detailed_description
    end
    def pass(description, message) puts "  + " + green("#{description} #{message}".strip); end

    def fail(description, message, line, file)
      puts "  - " + yellow("#{description}: #{message} #{line_info(line, file)}".strip)
    end

    def error(description, e) puts "  ! " + red("#{description}: #{e.message}"); end
  end # StoryReporter

  class VerboseStoryReporter < StoryReporter
    def error(description, e)
      super
      puts red(format_error(e))
    end
  end # VerboseStoryReporter

end # Riot

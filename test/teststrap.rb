$: << File.join(File.dirname(__FILE__), "..", "lib")
require 'riot'

module AssertionContextMacros
  def topic_should_pass
    asserts("passes") { topic.run(Riot::Situation.new)[0] }.equals(:pass)
  end

  def topic_should_fail(description="fails")
    asserts(description) { topic.run(Riot::Situation.new)[0] }.equals(:fail)
  end

  def topic_should_fail_with_message(*msgs)
    topic_should_fail
    msgs.each do |msg|
      asserts("should include #{msg} in error message") { topic.run(Riot::Situation.new)[1].include? msg }
    end
  end
end

Riot::Context.instance_eval { include AssertionContextMacros }

class MockReporter < Riot::Reporter
  def pass(description); end
  def fail(description, message); end
  def error(description, e); end
  def results; end
end

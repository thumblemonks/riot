$: << File.join(File.dirname(__FILE__), "..", "lib")
require 'riot'

module Riot
  module AssertionTestContextMacros

    def assertion_test_passes(description, &block)
      context(description) do
        setup(&block)
        asserts("passes") { topic.run(Riot::Situation.new) }.equals([:pass])
      end
    end

    def assertion_test_fails(description, failure_message, &block)
      context(description) do
        setup(&block)
        asserts("failure") { topic.run(Riot::Situation.new).first }.equals(:fail)
        asserts("failure message") { topic.run(Riot::Situation.new).last }.equals(failure_message)
      end
    end

  end # AssertionTestContextMacros
end # Riot

Riot::Context.instance_eval { include Riot::AssertionTestContextMacros }

class MockReporter < Riot::Reporter
  def pass(description); end
  def fail(description, message); end
  def error(description, e); end
  def results; end
end

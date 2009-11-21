require 'teststrap'

context "a reporter" do
  setup do
    Class.new(Riot::Reporter) do
      def pass(d) "passed(#{d})"; end
      def fail(d, message) "failed(#{d}, #{message})"; end
      def error(d, e) "errored(#{d}, #{e})"; end
    end.new
  end

  # pass

  asserts("pass count increase when :pass sent to #update") do
    topic.update("", [:pass])
    topic.passes
  end.equals(1)

  asserts("description sent to #pass") do
    topic.update("hi mom", [:pass])
  end.equals("passed(hi mom)")

  # fail

  asserts("fail count increase when :fail sent to #update") do
    topic.update("", [:fail, ""])
    topic.failures
  end.equals(1)

  asserts("description and message sent to #fail") do
    topic.update("hi mom", [:fail, "how are you"])
  end.equals("failed(hi mom, how are you)")

  # error

  asserts("error count increase when :error sent to #update") do
    topic.update("", [:error, ""])
    topic.errors
  end.equals(1)

  asserts("description sent to #error") do
    topic.update("break it down", [:error, "error time"])
  end.equals("errored(break it down, error time)")
end # a reporter

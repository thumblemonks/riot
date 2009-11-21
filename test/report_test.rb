require 'teststrap'

context "A reporter" do
  setup do
    Class.new(Riot::Reporter) do
      def pass(d) "passed(#{d})"; end
      def fail(d, message) "failed(#{d}, #{message})"; end
      def error(d, e) "errored(#{d}, #{e})"; end
    end.new
  end

  # pass

  asserts("pass count increase when :pass sent to #report") do
    topic.report("", [:pass])
    topic.passes
  end.equals(1)

  asserts("description sent to #pass") do
    topic.report("hi mom", [:pass])
  end.equals("passed(hi mom)")

  # fail

  asserts("fail count increase when :fail sent to #report") do
    topic.report("", [:fail, ""])
    topic.failures
  end.equals(1)

  asserts("description and message sent to #fail") do
    topic.report("hi mom", [:fail, "how are you"])
  end.equals("failed(hi mom, how are you)")

  # error

  asserts("error count increase when :error sent to #report") do
    topic.report("", [:error, ""])
    topic.errors
  end.equals(1)

  asserts("description sent to #error") do
    topic.report("break it down", [:error, "error time"])
  end.equals("errored(break it down, error time)")
end # A reporter

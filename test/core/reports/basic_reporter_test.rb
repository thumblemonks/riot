require 'teststrap'

context "A reporter" do
  setup do
    Class.new(Riot::Reporter) do
      def pass(d, message) "passed(#{d}, #{message.inspect})"; end
      def fail(d, message, line, file) "failed(#{d}, #{message} on line #{line} in file #{file})"; end
      def error(d, e) "errored(#{d}, #{e})"; end
      def results(time); end
    end.new
  end

  # pass

  asserts("pass count increase when :pass sent to #report") do
    topic.report("", [:pass])
    topic.passes
  end.equals(1)

  asserts("description sent to #pass") do
    topic.report("hi mom", [:pass])
  end.equals("passed(hi mom, nil)")

  # fail

  asserts("fail count increase when :fail sent to #report") do
    topic.report("", [:fail, ""])
    topic.failures
  end.equals(1)

  asserts("description, message, line and file sent to #fail") do
    topic.report("hi mom", [:fail, "how are you", 4, "foo"])
  end.equals("failed(hi mom, how are you on line 4 in file foo)")

  # error

  asserts("error count increase when :error sent to #report") do
    topic.report("", [:error, ""])
    topic.errors
  end.equals(1)

  asserts("error count increase when :setup_error sent to #report") do
    topic.report("", [:setup_error, ""])
    topic.errors
  end.equals(2)

  asserts("description sent to #error") do
    topic.report("break it down", [:error, "error time"])
  end.equals("errored(break it down, error time)")

  context "instance" do
    setup { Riot::Reporter.new }
    should("return self invoking new") { topic.new }.equals { topic }
    should("accept an options hash") { topic.new({}) }.equals { topic }
  end

  context "with no errors or failures" do
    hookup { topic.report("foo", [:pass, nil]) }
    asserts(:success?)
  end

  context "with failures and no errors" do
    hookup { topic.report("foo", [:fail, "blah"]) }
    asserts(:success?).equals(false)
  end

  context "with errors and no failures" do
    hookup { topic.report("foo", [:error, Exception.new("boogers")]) }
    asserts(:success?).equals(false)
  end
end # A reporter


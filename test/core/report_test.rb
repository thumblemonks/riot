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

  asserts("description sent to #error") do
    topic.report("break it down", [:error, "error time"])
  end.equals("errored(break it down, error time)")

  context "instance" do
    setup { Riot::Reporter.new }
    should("return self invoking new") { topic.new }.equals { topic }
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

require 'stringio'
context "StoryReporter" do
  setup do
    @out = StringIO.new
    Riot::StoryReporter.new(@out)
  end

  asserts("success message is stripped if nil") do
    topic.pass("foo", nil)
    ColorHelper.uncolored(@out.string)
  end.equals("  + foo\n")

  asserts("failure message excludes line info if none provided") do
    @out.rewind
    topic.fail("foo", "bar", nil, nil)
    ColorHelper.uncolored(@out.string)
  end.equals("  - foo: bar\n")

  context 'reporting on an empty context' do
    setup do
      context = Riot::Context.new('empty context') do
        context("a nested empty context") {}
      end
      context.run(topic)
    end
    should("not output context name") { @out.string }.empty
  end

  context "reporting on a non-empty context" do
    setup do
      context = Riot::Context.new('supercontext') do
        asserts("truth") { true }
      end
      context.run(topic)
    end

    should('output context name') { @out.string }.matches(/supercontext/)
    should('output name of passed assertion') { @out.string }.matches(/truth/)
  end
end

context "DotMatrixReporter" do
  setup do
    @out = StringIO.new
    Riot::DotMatrixReporter.new(@out)
  end

  context "with a passing test" do
    setup do
      context = Riot::Context.new('whatever') do
        asserts('true') { true }
      end
      context.run(topic)
      @out.string
    end
    asserts('puts a dot').matches('.')
  end
  
  context 'with a failing test' do
    setup do
      Riot::Context.new('whatever') do
        asserts('nope!') { false }
      end.run(topic)
      topic.results(100)
      @out.string
    end
    
    asserts('puts an F').matches('F')
    asserts("puts the full context + assertion name").matches('whatever asserts nope!')
    asserts("puts the failure reason").matches(/Expected .* but got false instead/)
  end
  
  context 'with an error test' do
    setup do
      Riot::Context.new('whatever') do
        asserts('bang') { raise "BOOM" }
      end.run(topic)
      topic.results(100)
      @out.string
    end
    
    asserts('puts an E').matches('E')
    asserts('puts the full context + assertion name').matches('whatever asserts bang')
    asserts('puts the exception message').matches('BOOM')
    asserts('puts the exception backtrace').matches(__FILE__)
  end
end

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

  context "instance" do
    setup { Riot::Reporter.new }

    should("return self invoking new") { topic.new }.equals { topic }
  end
end # A reporter

require 'stringio'
context "StoryReporter" do
  setup do
    @out = StringIO.new
    Riot::StoryReporter.new(@out)
  emd

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

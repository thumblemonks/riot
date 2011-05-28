require 'teststrap'

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
    asserts_topic('puts a dot').matches('.')
  end
  
  context 'with a failing test' do
    setup do
      Riot::Context.new('whatever') do
        asserts('nope!') { false }
      end.run(topic)
      topic.results(100)
      @out.string
    end
    
    asserts_topic('puts an F').matches('F')
    asserts_topic("puts the full context + assertion name").matches('whatever asserts nope!')
    asserts_topic("puts the failure reason").matches(/Expected .* but got false instead/)
  end
  
  context 'with an error test' do
    setup do
      Riot::Context.new('whatever') do
        asserts('bang') { raise "BOOM" }
      end.run(topic)
      topic.results(100)
      @out.string
    end
    
    asserts_topic('puts an E').matches('E')
    asserts_topic('puts the full context + assertion name').matches('whatever asserts bang')
    asserts_topic('puts the exception message').matches('BOOM')
    # <file path>:<one or more number><two newlines><anything till end of line><newline> is the last thing in the stack trace
    asserts_topic('puts the filtered exception backtrace').matches(/#{__FILE__}:\d+:[^\n]*\n\n.*$\n\z/)
  end
end


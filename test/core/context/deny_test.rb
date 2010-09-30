require 'teststrap'

context "Using denies" do

  context "with a test that should pass" do
    setup do
      Riot::Context.new("Apple Jackie") do
        denies("with false") { false }
      end.run(MockReporter.new)
    end

    asserts("passes, failures, errors") do
      [topic.passes, topic.failures, topic.errors]
    end.equals([1,0,0])
  end

  context "with a test that should fail" do
    setup do
      Riot::Context.new("Apple Jackie") do
        denies("with true") { true }
      end.run(MockReporter.new)
    end

    asserts("passes, failures, errors") do
      [topic.passes, topic.failures, topic.errors]
    end.equals([0,1,0])
  end

  context "with a test that should error" do
    setup do
      Riot::Context.new("Apple Jackie") do
        denies("ooooops") { raise Exception }
      end.run(MockReporter.new)
    end

    asserts("passes, failures, errors") do
      [topic.passes, topic.failures, topic.errors]
    end.equals([0,0,1])
  end

end # Calling context with deny

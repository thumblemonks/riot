require 'teststrap'

context "An assertion" do
  context "that is passing" do
    setup { Riot::Assertion.new("foo") { true } }
    asserts("to_s") { topic.to_s == "foo" }

    asserts(":pass is returned when evaluated") do
      topic.run(Riot::Situation.new) == [:pass, nil]
    end
  end # that is passing

  context "that is failing" do
    setup { Riot::Assertion.new("foo") { nil } }
    asserts("to_s") { topic.to_s == "foo" }

    asserts(":fail and message are evaluated") do
      topic.run(Riot::Situation.new) == [:fail, "Expected non-false but got nil instead"]
    end
  end # that is failing

  context "that is erroring" do
    setup do
      @exception = exception = Exception.new("blah")
      Riot::Assertion.new("baz") { raise exception }
    end

    asserts("to_s") { topic.to_s == "baz" }

    asserts(":error and exception are evaluated") do
      topic.run(Riot::Situation.new) == [:error, @exception]
    end
  end # that is erroring

  context "with no block to provide the actual value" do
    setup do
      @situation = Riot::Situation.new
      @situation.topic = "hello"
      Riot::Assertion.new("test")
    end
    should("uses block returning topic as default") do
      topic.equals("hello")
      result = topic.run(@situation)
    end.equals([:pass, %Q{is equal to "hello"}])
  end # with no block to provide the actual value
  
  context "with block expectation" do
    setup do
      @situation = Riot::Situation.new
      @situation.topic = "hello"
      Riot::Assertion.new("test")
    end

    should("use block returning topic as default") do
      topic.equals { "hello" }
      result = topic.run(@situation)
    end.equals([:pass, %Q{is equal to "hello"}])

    asserts("block expectation has access to the situation items") do
      topic.equals { @topic }
      topic.run(@situation)
    end.equals([:pass, %Q{is equal to "hello"}])
  end # with block expectation

  context "with symbolic description" do
    setup { "foo" }
    asserts(:upcase).equals("FOO")
  end
end # An assertion block

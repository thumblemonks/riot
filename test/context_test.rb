require 'teststrap'

context "any context" do
  setup do
    @reporter = Riot::NilReport.new
    @context = Riot::Context.new("a", @reporter)
  end

  context "that doesn't have passing tests" do
    setup do
      @context.should("a") { true }
      @context.should("b") { false }
      @context.should("c") { raise Exception, "blah" }
      @context.report
    end

    asserts("passed test count") { @reporter.passes }.equals(1)
    asserts("failure count") { @reporter.failures }.equals(1)
    asserts("unexpected errors count") { @reporter.errors }.equals(1)
  end # that doesn't have passing tests

  context "when running setup:" do
    setup { @context.setup { "foo" } }

    asserts "topic becomes available to test as result of setup" do
      @context.should("bar") { topic }.actual
    end.equals("foo")

    asserts "calling topic in context will return assertion that returns topic as the actual" do
      @context.topic.actual
    end.equals("foo")
  end # when running setup
end # any context

# 
# Basic Context

context "basic context" do
  setup do
    test_context = Riot::Context.new("foo", Riot::NilReport.new)
    test_context.setup { @test_counter = 0 }
    test_context.asserts("truthiness") { @test_counter += 1; true }
    test_context.asserts("more truthiness") { @test_counter += 1; true }
    test_context
  end

  asserts("context description") { topic.to_s }.equals("foo")
  asserts("assertion count") { topic.assertions.length }.equals(2)
  should("call setup once per context") { topic.situation }.assigns(:test_counter, 2)
end # basic context

# 
# Nested Context

context "nested context" do
  setup do
    @parent_context = Riot::Context.new("foo", Riot::NilReport.new)
    @parent_context.setup { @test_counter = 0; @foo = "bar" }
    @parent_context.asserts("truthiness") { @test_counter += 1; true }
    @parent_context
  end
  
  context "inner context with own setup" do
    setup do
      test_context = @parent_context.context("baz")
      test_context.setup { @test_counter += 10 }
      test_context
    end
  
    should("inherit parent context") { topic.situation }.assigns(:test_counter, 10)
    should("chain context names") { topic.to_s }.equals("foo baz")
  end

  context "inner context without its own setup" do
    setup { @parent_context.context("bum") }
    asserts("parent setup is called") { topic.situation }.assigns(:foo, "bar")
  end
end

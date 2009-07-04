require 'protest'
require 'stringio'

context "any context" do
  setup do
    @reporter = Protest::NilReport.new
    @context = Protest::Context.new("a", @reporter)
  end

  # denies("two contexts with same name are the same").equals(@context) { Protest::Context.new("a") }

  context "that doesn't have passing tests" do
    setup do
      @context.asserts("a") { true }
      @context.asserts("b") { false }
      @context.asserts("c") { raise Exception, "blah" }
    end

    asserts("that passes are disctinct") { @reporter.passes }.equals(1)
    asserts("that failures are captured") { @reporter.failures }.equals(1)
    asserts("that unexpected errors are captured") { @reporter.errors }.equals(1)
  end # that doesn't have passing tests
end # any context

context "when denying things" do
  denies("true is false") { false }
  denies("bar equals foo") { "bar" }.equals("foo")
  denies("bar matches only digits") { "bar" }.matches(/^\d+$/)
end

# 
# Test Context

test_context = context("foo", Protest::NilReport.new) do
  setup { @test_counter = 0 }
  asserts("a block returns true") { @test_counter += 1; true }
  asserts("another block returns true") { @test_counter += 1; true }
end # A CONTEXT THAT IS DEQUEUED

context "test context" do
  setup { Protest.dequeue_context(test_context) }
  asserts("context description") { test_context.to_s }.equals("foo")
  asserts("assertion count") { test_context.assertions.length }.equals(2)

  asserts("setup runs only once") do
    test_context.instance_variable_get(:@test_counter)
  end.equals(2)
end

# 
# Nested Context

inner_nested_context, other_nested_context = nil, nil
nested_context = context("foo", Protest::NilReport.new) do
  setup do
    @test_counter = 0
    @foo = "bar"
  end
  asserts("a block returns true") { @test_counter += 1; true }
  
  inner_nested_context = context("baz") do
    setup { @test_counter += 10 }
  end # A CONTEXT THAT IS DEQUEUED

  other_nested_context = context("bum") {} # A CONTEXT THAT IS DEQUEUED
end # A CONTEXT THAT IS DEQUEUED

context "nested context" do
  setup do
    [nested_context, inner_nested_context, other_nested_context].each do |c|
      Protest.dequeue_context(c)
    end
  end
  
  asserts("inner context inherits parent context setup") do
    inner_nested_context.instance_variable_get(:@test_counter)
  end.equals(10)

  asserts("nested context name") { inner_nested_context.to_s }.equals("foo baz")

  asserts("inner context without setup is still bootstrapped") do
    other_nested_context.instance_variable_get(:@foo)
  end.equals("bar")
end

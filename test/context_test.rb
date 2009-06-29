require 'protest'
require 'stringio'

context "any context" do
  setup do
    @context = Protest::Context.new("a")
  end

  denies("two contexts with same name are the same").equals(@context) { Protest::Context.new("a") }

  context "that doesn't have passing tests" do
    setup do
      @report = Protest::NilReport.new
      @context.asserts("a") { true }
      @context.asserts("b") { false }
      @context.asserts("c") { raise Exception, "blah" }
      @context.run(@report)
    end

    asserts("that passes are disctinct").equals(1) { @report.passes }
    asserts("that failures are captured").equals(1) { @report.failures }
    asserts("that unexpected errors are captured").equals(1) { @report.errors }
  end # that doesn't have passing tests
end # any context

# 
# Test Context

test_context = context "foo" do
  setup { @test_counter = 0 }
  asserts("a block returns true") { @test_counter += 1; true }
  asserts("another block returns true") { @test_counter += 1; true }
end # A CONTEXT THAT IS DEQUEUED

context "test context" do
  setup { Protest.dequeue_context(test_context) }
  asserts("context description").equals("foo") { test_context.to_s }
  asserts("assertion count").equals(2) { test_context.assertions.length }

  asserts("setup runs only once").equals(2) do
    test_context.run(Protest::NilReport.new)
    test_context.instance_variable_get(:@test_counter)
  end
end

# 
# Nested Context

inner_nested_context, other_nested_context = nil, nil
nested_context = context "foo" do
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
      c.run(Protest::NilReport.new)
    end
  end
  
  asserts("inner context inherits parent context setup").equals(10) do
    inner_nested_context.instance_variable_get(:@test_counter)
  end

  asserts("nested context name").equals("foo baz") do
    inner_nested_context.to_s
  end

  asserts("inner context without setup is still bootstrapped").equals("bar") do
    other_nested_context.instance_variable_get(:@foo)
  end
end

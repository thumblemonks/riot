require 'protest'
require 'stringio'

context "any context" do
  setup do
    @context = Protest::Context.new("a")
  end

  # denies("two contexts with same name are the same").equals(@context) { Protest::Context.new("a") }

  context "that doesn't have passing tests" do
    setup do
      @context.asserts("b") { false }
      @context.asserts("c") { raise Exception, "blah" }
      @context.run(StringIO.new)
    end

    asserts("that failures are captured").equals(1) do
      @context.failures.select{|e| e.class == Protest::Failure}.length
    end

    asserts("that unexpected errors are captured").equals(1) do
      @context.failures.select{|e| e.class == Protest::Error}.length
    end
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
    test_context.run(StringIO.new)
    test_context.instance_variable_get(:@test_counter)
  end
end

# 
# Nested Context

inner_nested_context = nil
nested_context = context "foo" do
  setup do
    @test_counter = 0
  end
  asserts("a block returns true") { @test_counter += 1; true }
  
  inner_nested_context = context("baz") do
    setup { @test_counter += 10 }
  end # A CONTEXT THAT IS DEQUEUED
end # A CONTEXT THAT IS DEQUEUED

context "nested context" do
  setup do
    Protest.dequeue_context(nested_context)
    Protest.dequeue_context(inner_nested_context)
    nested_context.run(StringIO.new)
    inner_nested_context.run(StringIO.new)
  end
  
  asserts("inner context inherits parent context setup").equals(10) do
    inner_nested_context.instance_variable_get(:@test_counter)
  end

  asserts("nested context name").equals("foo baz") do
    inner_nested_context.to_s
  end
end

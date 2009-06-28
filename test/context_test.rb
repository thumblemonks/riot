require 'test_helper'
require 'stringio'

test_context = context "foo" do
  setup { @test_counter = 0 }

  asserts("a block returns true") { @test_counter += 1; true }
  asserts("another block returns true") { @test_counter += 1; true }
end

context "test context" do
  setup do
    Protest.dequeue_context(test_context)
  end

  asserts("context description").equals("foo") { test_context.to_s }
  asserts("assertion count").equals(2) { test_context.assertions.length }

  asserts("setup runs only once").equals(2) do
    test_context.run(StringIO.new)
    test_context.instance_variable_get(:@test_counter)
  end
end

context "any context" do
  denies("two contexts with same name are the same").equals(Protest::Context.new("a")) do
    Protest::Context.new("a")
  end
end

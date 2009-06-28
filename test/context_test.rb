require 'test_helper'

test_context = context "foo" do
  setup do
    @test_counter = 0
  end

  asserts "a block returns true" do
    @test_counter += 1
    true
  end

  asserts "another block returns true" do
    @test_counter += 1
    true
  end
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
require 'teststrap'

global_thang = Struct.new(:count).new(0)

context "A context with a teardown" do
  setup do
    @a_context = Riot::Context.new("me") do
      setup { global_thang.count += 1 }
      asserts("teardown run") { global_thang.count }.equals(1)
      teardown { global_thang.count += 1 }
    end
    @a_context.run(MockReporter.new)
  end

  asserts("test passed") { topic.passes }.equals(1)
  asserts("teardown run") { global_thang.count }.equals(2)
  
  context "that has a nested context with teardowns" do
    setup do
      @a_context.context "nested" do
        setup { global_thang.count = 0 }
        asserts("no teardowns run") { global_thang.count }.equals(0)
        teardown { global_thang.count += 2 }
      end
      @a_context.run(MockReporter.new)
    end
    asserts("tests passed") { topic.passes }.equals(1)
    asserts("teardowns ran in local and parent context") { global_thang.count }.equals(3)
  end # that has a nested context with teardowns

  context "that has multiple teardowns in nested context" do
    setup do
      @a_context.context "nested" do
        setup { global_thang.count = 0 }
        teardown { global_thang.count += 2 }
        teardown { global_thang.count += 2 }
      end
      @a_context.run(MockReporter.new)
    end
    asserts("teardowns ran in local and parent context") { global_thang.count }.equals(5)
  end # that has multiple teardowns in nested context
end # A context with a teardown

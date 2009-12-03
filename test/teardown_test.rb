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
  
  context "with a nested context with teardowns" do
    setup do
      @a_context.context "nested" do
        setup { global_thang.count = 0 }
        asserts("no teardowns run") { global_thang.count }.equals(0) 
        teardown { global_thang.count += 1 }
      end
      @a_context.run(MockReporter.new)
    end
    asserts("tests passed") { topic.passes }.equals(1)
    asserts("teardowns run") { global_thang.count }.equals(2)
  end
end

require 'teststrap'

context "ContextMiddleware" do
  setup { Riot::ContextMiddleware.new }
  teardown { Riot::Context.middlewares.clear }

  asserts("handle? with context") { topic.handle?("Foo") }.equals(false)
  asserts("call with context") { topic.call("Foo") }.nil

  context "registration" do
    setup { Class.new(Riot::ContextMiddleware) { register } }
    asserts("registered middlewares list") { Riot::Context.middlewares }.size(1)
    asserts("registered middleware") { Riot::Context.middlewares.first }.kind_of(Riot::ContextMiddleware)
  end # registration

  context "that is not meant to be used" do
    hookup do
      Class.new(Riot::ContextMiddleware) do
        register
        def handle?(context) context.description == "Bar"; end
        def call(context) context.setup { "fooberries" }; end
      end
    end

    setup do
      Riot::Context.new("Foo") { asserts_topic.nil }.run(MockReporter.new)
    end

    asserts("tests passed") { topic.passes }.equals(1)
  end # that is not meant to be used

  context "that is meant to be used" do
    hookup do
      Class.new(Riot::ContextMiddleware) do
        register
        def handle?(context); true; end
        def call(context) context.setup { "fooberries" }; end
      end
    end

    setup do
      Riot::Context.new("Foo") { asserts_topic.equals("fooberries") }.run(MockReporter.new)
    end

    asserts("tests passed") { topic.passes }.equals(1)
  end # that is meant to be used

  context "applied in multiples" do
    hookup do
      Class.new(Riot::ContextMiddleware) do
        register
        def handle?(context); true; end
        def call(context) context.setup { "foo" }; end
      end
    end

    hookup do
      Class.new(Riot::ContextMiddleware) do
        register
        def handle?(context); true; end
        def call(context) context.setup { topic + "berries" }; end
      end
    end

    setup do
      Riot::Context.new("Foo") { asserts_topic.equals("fooberries") }.run(MockReporter.new)
    end

    asserts("tests passed") { topic.passes }.equals(1)
  end # that are not exclusive

  context "has access to options" do
    hookup do
      Class.new(Riot::ContextMiddleware) do
        register
        def handle?(context); context.option(:foo) == "bar"; end
        def call(context) context.setup { "fooberries" }; end
      end
    end

    setup do
      Riot::Context.new("Foo") do
        set :foo, "bar"
        asserts_topic.equals("fooberries")
      end.run(MockReporter.new)
    end

    asserts("tests passed") { topic.passes }.equals(1)
  end # has access to options
end # ContextMiddleware

require 'teststrap'

context "ContextMiddleware" do
  setup { Riot::ContextMiddleware.new("") }
  teardown { Riot::Context.middlewares.clear }

  asserts("#call on the base class") do
    topic.call("Foo")
  end.raises(RuntimeError, "You should implement call yourself")

  context "registration" do
    setup { Class.new(Riot::ContextMiddleware) { register } }
    asserts("registered middlewares list") { Riot::Context.middlewares }.size(1)
    asserts("registered middleware") { Riot::Context.middlewares.first }.kind_of(Class)
  end # registration

  context "that is not meant to be used" do
    hookup do
      Class.new(Riot::ContextMiddleware) do
        register
        # def handle?(context) context.description == "Bar"; end
        def call(context)
          context.setup { "fooberries" } if context.description == "Bar"
          middleware.call(context)
        end
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
        # def handle?(context); true; end
        def call(context)
          context.setup { "fooberries" }
          middleware.call(context)
        end
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
        def call(context)
          context.setup { topic + "berries" }
          middleware.call(context)
        end
      end
    end

    hookup do
      Class.new(Riot::ContextMiddleware) do
        register
        def call(context)
          context.setup { "foo" }
          middleware.call(context)
        end
      end
    end

    setup do
      Riot::Context.new("Foo") { asserts_topic.equals("fooberries") }.run(MockReporter.new)
    end

    asserts("tests passed") { topic.passes }.equals(1)
  end # that are not exclusive

  context "has access to options after context setup" do
    hookup do
      Class.new(Riot::ContextMiddleware) do
        register
        def call(context)
          middleware.call(context)
          context.setup { "fooberries" } if context.option(:foo) == "bar"
        end
      end
    end

    setup do
      Riot::Context.new("Foo") do
        set :foo, "bar"
        asserts_topic.equals("fooberries")
      end.run(MockReporter.new)
    end

    asserts("tests passed") { topic.passes }.equals(1)
  end # has access to options after context setup

  context "that errors while preparing" do
    hookup do
      Class.new(Riot::ContextMiddleware) do
        register
        def call(context)
          raise Exception.new("Banana pants")
        end
      end
    end

    setup do
      Riot::Context.new("Foo") { asserts_topic.nil }.run(MockReporter.new)
    end

    asserts("tests passed") { topic.passes }.equals(0)
    asserts("tests failed") { topic.failures }.equals(0)
    asserts("tests errored") { topic.errors }.equals(1)
  end # that is not meant to be used

end # ContextMiddleware

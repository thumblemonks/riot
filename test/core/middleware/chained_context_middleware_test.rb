require 'teststrap'

context "Chaining ContextMiddleware" do

  teardown { Riot::Context.middlewares.clear }

  context("when middleware halts the call chain") do
    hookup do
      Class.new(Riot::ContextMiddleware) do
        register
        def initialize(middleware); end
        def call(context) "whoops"; end
      end
    end

    setup do
      situation = Riot::Situation.new
      Riot::Context.new("Foo") do
        setup { "foo" }
      end.local_run(MockReporter.new, situation)
      situation
    end

    asserts("situation topic") { topic.topic }.nil
  end # when middleware halts the call chain

  context("when middleware continues the call chain") do
    hookup do
      Class.new(Riot::ContextMiddleware) do
        register
        def call(context)
          context.setup { ["foo"] }
          middleware.call(context)
          context.hookup { topic << "baz" }
        end
      end
    end

    setup do
      situation = Riot::Situation.new
      Riot::Context.new("Foo") do
        hookup { topic << "bar" }
      end.local_run(MockReporter.new, situation)
      situation
    end

    asserts("situation topic") { topic.topic }.equals(%w[foo bar baz])
  end # when middleware halts the call chain
end # Chaining ContextMiddleware

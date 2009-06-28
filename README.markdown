# Protest

An extremely fast-running, context-driven, unit testing framework.

    context "Foo" do
      setup do
        # some setup stuff
        @foo = Foo.new
      end
      
      asserts("this block returns true") do
        true
      end

      asserts("this block returns a specific string").equals("my friend") do
        @foo.your_mom
      end
    end

Protest differs in that it does not rerun setup for each test in a context. Each assertion should not mangle the context and therefore not require setup to be run more than once. Contexts can be nested ...

MORE TO COME
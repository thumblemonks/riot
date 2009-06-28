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

MORE TO COME

## You say, "OMG! Why did you write this?"

#### Some background, I guess

You start a new project. You get all excited. You're adding tests. You're adding factories. You're fixturating your setups. You're adding more tests. Your tests start slowing down, but you need to keep pushing because your backlog has a lot of new, nifty features in it. You've got 3000+ lines of test code, 2000+ assertions. Your tests are annoyingly slow. Your tests have become a burden.

I hate this and it happens a lot, even when I'm conscience that it's happening.

#### How Protest is different

Protest differs in that it does not rerun setup for each test in a context. Each assertion should not mangle the context and therefore not require setup to be run more than once. Contexts can be nested and setups inherited, but setup is called only once per context.

...

You say, "Ok, but Shoulda is like this!"

Well, it is ... sort of. I love Shoulda. It changed the way I coded. But, Shoulda is slow. Shoulda is based on Test::Unit. Shoulda reruns setups for every should. Shoulda could make my life even easier with some more expressiveness.

#### How Protest is the same

It defines a context. It prints .'s, F's, and E's when tests pass, fail, or error.

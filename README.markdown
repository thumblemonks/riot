# Protest

An extremely fast-running, context-driven, unit testing framework.

    context "Foo" do
      setup do
        @foo = Foo.new
      end
      
      asserts("this block returns true") { true }

      asserts("this block returns a specific string").equals("my friend") do
        @foo.your_mom
      end
    end

MORE TO COME

## You say, "OMG! Why did you write this?"

### Some background, I guess

You start a new project. You get all excited. You're adding tests. You're adding factories. You're fixturating your setups. You're adding more tests. Your tests start slowing down, but you need to keep pushing because your backlog has a lot of new, nifty features in it. You've got 3000+ lines of test code, 2000+ assertions. Your tests are annoyingly slow. Your tests have become a burden.

I hate this and it happens a lot, even when I'm conscience that it's happening. Even when I'm not hitting the database and I'm mocking the crap out my code.

I really, really hate slow test suites.

#### Did ... you look at Shoulda

I should say that I love Shoulda in theory and in practice. It changed the way I coded. I added macros all over the place. I built macros into the gems I wrote for the gem itself. But, alas, Shoulda is slow. Shoulda is based on Test::Unit. Shoulda reruns setups for every should. Shoulda could make my life even easier with even more expressiveness.

#### Did ... you look at RSpec

:| yes, no, I don't care. It's slow, too. Anyways, I was at [ObjectMentor](http://objectmentor.com) many, many moons ago when Dave Astels (accompanied by David Chelimsky) were explaining this brand new approach to testing called BDD. Mr. Astels explained to us that we if we already understood TDD, then BDD wouldn't help a bunch. Why argue with him?

### How Protest is the same

1. It defines a context
1. It prints .'s, F's, and E's when tests pass, fail, or error
1. It tells you how long it took to run just the tests
1. Contexts can be nested and setups inherited

### How Protest is different

Protest differs primarily in that it does not rerun setup for each test in a context. I know this is going to shock and awe a lot of folks. However, over the past several years of my doing TDD in some capacity or another, there are certain habits I have tried to pick up on any many others I have tried to drop.

For instance, I believe that no assertion should mangle the context of the test data it is running in. Following this allows me to require setup be run only once for a collection of related assertions. Even in a nested context where setups are inherited, the setup's are called only once per the specific context.

Following all of this allows me to have very fast tests (so far).

...

Protest is also different in that assertions are not added to the test block. Each test block is it's own assertion (and assertion block). Whatever the result is of processing an assertion block will be used to determine if an assertion passed or failed. Each assertion block can have a specific validator tied to it for asserting any number of things, like: the result of the test **equals** some expected value, the result of the test **matches** some expected expression, or the result of the test **raises** some exception.

I like this approach because I only want to test one thing, but that one thing may require some work on my behalf to get the value. Protest does not let me cheat in this regard. There is no way for me to add more than one assertion to an assertion block.

...

I imagine this approach will persuade many of you to avoid Protest altogether. I don't blame you. A few years ago I would have avoided it, too. As of this writing though, I have ported Chicago and Slvu (which were previously written in Test::Unit + Shoulda) to Protest, cut the number of lines of code in almost half, definitely more than halved the amount of time the tests took to run, and did so in less than half a day (I was building Protest while porting them :).

## Running tests

Create or modify your existing Rakefile to define a test task like so:

    desc 'Default task: run all tests'
    task :default => [:test]
    
    desc "Run all tests"
    task :test do
      require 'protest'
      $:.concat ['./lib', './test']
      Dir.glob("./test/*_test.rb").each { |test| require test }
      Protest.run
    end

Then, from the command line, you only need to run `rake` or `rake test`. Please make sure to remove all references to any other testing frameworks before running tests. For instance, do not require `test/unit`, `shoulda`, `minitest`, or anything else like it.

### With Sinatra

Protest definitely works with the latest Sinatra. I personally use it to run tests for [Chicago](http://github.com/thumblemonks/chicago) and [Slvu](http://github.com/jaknowlden/slvu). Setup is pretty easy and very much like getting your tests to run with Test::Unit. In a test helper file that gets loaded into all of your tests (that need it), enter the following:

    require 'protest'
    class Protest::Context
      include Rack::Test::Methods
      def app; @app; end
    end

And then define a context (or many) for testing your Sinatra app. For instance:

    require 'test_helper'
    
    context 'Some App' do
      setup { @app = SomeApp }
      
      context "/index" do
        setup { get '/' }
        # ...
      end
    end

Make sure to check out the Protest + Sinatra testing macros in Chicago.

### With Rails
    
It's doubtful that Protest works with Rails very easily as Protest completely replaces Test::Unit. I haven't tried it yet, but intend to with my next new Rails project. Porting would probably take some time unless you only have a few test cases.

## Extending Protest with Macros

To extend Protest, similar to how you would with Shoulda, you simply need to include your methods into the `Protest::Context` class. For example, let's say you wanted to add a helpful macro for asserting the response status of some HTTP result in Sinatra. You could do this easily by defining your macro like so:

    module Custom
      module Macros
        def asserts_response_status(expected)
          asserts("response status is #{expected}").equals(expected) do
            last_response.status
          end
        end
      end # Macros
    end # Custom
    Protest::Context.instance_eval { include Custom::Macros }

And then in your actual test, you might do the following:

    context 'Some App' do
      setup { @app = SomeApp }
  
      context "/index" do
        setup { get '/' }
        asserts_respons_status 200
      end
    end

**COMING SOON:** Protest will look into test/protest\_macros, but not today.

#### Assertion macros
If you want to add special macros to an Assertion, this is only slightly more tricky. The trickiness is simply understanding when and why to do so. Assertion macros are statements that can be appended to `asserts` or `denies` statements; similar to the `equals` or `raises` statements. Your assertion must know how and when to evaluate the provided block (if there is one), and what a failure looks like. Similar to Context macros, Assertion macros are included into the Assertion class.

For instance, let's say you wanted to add a macro for verifying that the result of an assertion is the same kind\_of object as you would expect. You would define the macro like so:

    module Custom
      module AssertionMacros
        def kind_of(expected, &block)
          assert_block do |scope|
            actual = scope.instance_eval(&block)
            actual.kind_of?(expected) || failure("expected kind of #{expected}, not #{actual.inspect}")
          end
        end
      end # AssertionMacros
    end # Custom
    Protest::Assertion.instance_eval { include Custom::AssertionMacros }

And in your context, you would use it like so:

    context "example" do
      asserts("a hash is defined").kind_of(Hash) do
        {:foo => 'bar'}
      end
    end

The `assert_block` is important because it defers execution until the assertion is evaluated.

*NOTE:* I welcome alternatives as I am really not digging this approach. Everything else is mostly to my liking.

## TODO

TONS OF STUFF

1. Documentation
1. More assertion macros: kind\_of, throws, etc.
1. Handle assertion macros better
1. Handle denies macro different, so that an entire failure message can translated to the 'negative' assertion
1. Perhaps: association macro chaining
1. Optimization

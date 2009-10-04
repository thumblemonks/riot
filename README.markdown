# Riot

An extremely fast, expressive, and context-driven unit-testing framework. Protest the slow test.

### Note on speed

I have done a really simple benchmarking, but right now, Riot is running about **10-times** faster than Test::unit and thusly Shoulda:

    $ ruby test/benchmark/simple_context_and_assertions.rb

    Rehearsal ----------------------------------------------
    Riot         0.140000   0.010000   0.150000 (  0.156170)
    Test::Unit   1.460000   0.000000   1.460000 (  1.495990)
    Shoulda      1.490000   0.010000   1.500000 (  1.514745)
    ------------------------------------- total: 3.110000sec

                     user     system      total        real
    Riot         0.130000   0.000000   0.130000 (  0.139770)
    Test::Unit   1.600000   0.010000   1.610000 (  1.627493)
    Shoulda      1.610000   0.010000   1.620000 (  1.655394)

    Loaded suite test/benchmark/simple_context_and_assertions

"Is it valid?", you ask. *I* think it is. I ain't no cheater, but I might be delusional.

#### Example: Basic booleans

**NOTE:** For no specific reason, I'm going to use an ActiveRecord model in the following examples.

At it's very basic, Riot simply tries to assert that an expression is true or false. Riot does this through its `asserts` or `should` tests. An `asserts` test will pass if the result of running the test is neither `nil` or `false`. A `should` test does the exact same thing - they are in fact aliases. The only difference is in the way you write the assertion. 

For instance, given a test file named `foo_test.rb`, you might have the following code in it:

    require 'riot'
    
    context "a new user" do
      setup { @user = User.new }
      asserts("that it is not yet created") { @user.new_record? }
    end

Notice that you do not define a class anywhere. That would be the entire contents of that test file. If you wanted to use a `should` instead, you could say this:

    require 'riot'

    context "a new user" do
      setup { @user = User.new }
      should("not be created") { @user.new_record? }
    end

Sometimes it's more clear to say "this **should** be that" and sometimes it's better to say "**asserts** this is that". I promise you that Riot will get no more redundant than this, but also that besides speed, Riot will aim at being expressive with a minimal amount of syntax.

I'm going to use `asserts` for the rest of this introduction, but you should know that you can replace any instance of `asserts` with `should` and nothing would change.

#### Example: Equality

One of the most common assertions you will (or do already) utilize is that of equality; is this equal to that? Riot supports this in a slightly different manner than most other frameworks. With Riot, you add the expectation to the assertion itself.

For example:

    context "a new user" do
      setup { @user = User.new(:email => 'foo@bar.com') }
      asserts("email address") { @user.email }.equals('foo@bar.com')
    end

Here, you should begin to notice that tests themselves return the actual value. You do not write assertions into the test. Assertions are "aspected" onto the test. If the test above did not return 'foo@bar.com' for `@user.email`, the assertion would have failed.

The `equals` modifier works with any type of value, including nil's. However, if you wanted to test for nil explicitly, you could simply do this:

    context "a new user" do
      setup { @user = User.new }
      asserts("email address") { @user.email }.nil
    end

Notice the `nil` modifier added to asserts. Also notice how the test almost reads as "a new user asserts email address *is* nil". With Test::Unit, you would have probably written:

    class UserTest < Test::Unit::TestCase
      def setup
        @user = User.new
      end
      
      def test_email_address_is_nil
        assert_nil @user.email
      end
    end

Which, to me, seems like a redundancy. The test already says it's nil! Maybe Shoulda woulda helped:

    class UserTest < Test::Unit::TestCase
      def setup
        @user = User.new
      end
  
      should "have nil email" { assert_nil @user.email }
    end

In my opinion, the same redundancy exists. Sure, I could write a macro like `should_be_nil {@user.email}`, but the redundancy exists in the framework itself.

#### Example: Matches

If you need to assert that a test result matches a regular expression, use the `matches` modifier like so:

    context "a new user" do
      setup { @user = User.new }

      # I'm a contrived example
      asserts("random phone number") { @user.random_phone_number }.matches(/^\d{3}-\d{3}-\d{4}$/)
    end

#### Example: Raises

Sometimes, your test raises an exception that you actually expected.

    context "a new user" do
      setup { @user = User.new }
      asserts("invalid data") { @user.save! }.raises(ActiveRecord::RecordInvalid)
    end

#### Example: Kind Of

When you want to test that an expression returns an object of an expected type:

    context "a new user" do
      setup { @user = User.new }
      asserts("its balance") { @user.balance }.kind_of(Currency)
    end

#### Example: Nested contexts

Oh yeah, Riot does those, too. The `setup` from each parent is "loaded" into the context and then the context is executed as normal. Test naming is a composite of the parent contexts' names. Here, we'll do a little Sinatra testing (see below for instructions on how to make it Riot work seamlessly with Sinatra tests).

    context "My App:" do
      setup { @app = MyApp }

      context "get /" do
        setup { get '/' }
        # ...
        # assertions

        context "renders a body" do
          setup { @body = last_response.body }
          # ...
          # assertions 
        end
      end
      
      context "get /books/1" do
        setup { get '/books/1' }
        # ...
        # assertions
      end
    end

#### More examples/documentation

There are many more basic assertion modifiers to come. See below for writing Riot extensions if you want to help out.

See the TODO section for everything that's missing.

Also, see [the wiki](http://wiki.github.com/thumblemonks/riot) for more examples and documentation.

## You say, "OMG! Why did you write this?"

### Some background, I guess

You start a new project. You get all excited. You're adding tests. You're adding factories. You're fixturating your setups. You're adding more tests. Your tests start slowing down, but you need to keep pushing because your backlog has a lot of new, nifty features in it. You've got 3000+ lines of test code, 2000+ assertions. Your tests are annoyingly slow. Your tests have become a burden.

I hate this and it happens a lot, even when I'm conscience that it's happening. Even when I'm not hitting the database and I'm mocking the crap out my code.

I really, really hate slow test suites.

#### Did ... you look at Shoulda

I should say that I love Shoulda in theory and in practice. It changed the way I coded. I added macros all over the place. I built macros into the gems I wrote for the gem itself. But, alas, Shoulda is slow. Shoulda is based on Test::Unit. Shoulda reruns setups for every should. Shoulda could make my life even easier with even more expressiveness.

#### Did ... you look at RSpec

:| yes, no, I don't care. It's slow, too. Anyways, I was at [ObjectMentor](http://objectmentor.com) many, many moons ago when Dave Astels (accompanied by David Chelimsky) were explaining this brand new approach to testing called BDD. Mr. Astels explained to us that we if we already understood TDD, then BDD wouldn't help a bunch. Why argue with him?

### How Riot is the same

1. It defines a context
1. It prints .'s, F's, and E's when tests pass, fail, or error
1. It tells you how long it took to run just the tests
1. Contexts can be nested and setups inherited

### How Riot is different

Riot differs primarily in that it does not rerun setup for each test in a context. I know this is going to shock and awe a lot of folks. However, over the past several years of my doing TDD in some capacity or another, there are certain habits I have tried to pick up on any many others I have tried to drop.

For instance, I believe that no assertion should mangle the context of the test data it is running in. Following this allows me to require setup be run only once for a collection of related assertions. Even in a nested context where setups are inherited, the setup's are called only once per the specific context.

Following all of this allows me to have very fast tests (so far).

...

Riot is also different in that assertions are not added to the test block. Each test block is it's own assertion (and assertion block). Whatever the result is of processing an assertion block will be used to determine if an assertion passed or failed. Each assertion block can have a specific validator tied to it for asserting any number of things, like: the result of the test **equals** some expected value, the result of the test **matches** some expected expression, or the result of the test **raises** some exception.

I like this approach because I only want to test one thing, but that one thing may require some work on my behalf to get the value. Riot does not let me cheat in this regard. There is no way for me to add more than one assertion to an assertion block.

...

I imagine this approach will persuade many of you to avoid Riot altogether. I don't blame you. A few years ago I would have avoided it, too. As of this writing though, I have ported Chicago and Slvu (which were previously written in Test::Unit + Shoulda) to Riot, cut the number of lines of code in almost half, definitely more than halved the amount of time the tests took to run, and did so in less than half a day (I was building Riot while porting them :).

## Running tests

Create or modify your existing Rakefile to define a test task like so:

    desc 'Default task: run all tests'
    task :default => [:test]
    
    desc "Run all tests"
    task :test do
      require 'riot'
      $:.concat ['./lib', './test']
      Dir.glob("./test/*_test.rb").each { |test| require test }
      Riot.report
    end

Then, from the command line, you only need to run `rake` or `rake test`. Please make sure to remove all references to any other testing frameworks before running tests. For instance, do not require `test/unit`, `shoulda`, `minitest`, or anything else like it.

### With Sinatra

Riot definitely works with the latest Sinatra. I personally use it to run tests for [Chicago](http://github.com/thumblemonks/chicago) and [Slvu](http://github.com/jaknowlden/slvu). Setup is pretty easy and very much like getting your tests to run with Test::Unit. In a test helper file that gets loaded into all of your tests (that need it), enter the following:

    require 'riot'
    class Riot::Context
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

Make sure to check out the Riot + Sinatra testing macros in Chicago.

### With Rails
    
It's doubtful that Riot works with Rails very easily as Riot completely replaces Test::Unit. I haven't tried it yet, but intend to with my next new Rails project. Porting would probably take some time unless you only have a few test cases. Porting is made somewhat easier if you're already using Shoulda; you can replace the `TestCase` definition with a `context` of the same name as the class under test I suppose.

## Extending Riot with Macros

To extend Riot, similar to how you would with Shoulda, you simply need to include your methods into the `Riot::Context` class. For example, let's say you wanted to add a helpful macro for asserting the response status of some HTTP result in Sinatra. You could do this easily by defining your macro like so:

    module Custom
      module Macros
        def asserts_response_status(expected)
          asserts("response status is #{expected}") do
            last_response.status
          end.equals(expected)
        end
      end # Macros
    end # Custom
    Riot::Context.instance_eval { include Custom::Macros }

And then in your actual test, you might do the following:

    context 'Some App' do
      setup { @app = SomeApp }
  
      context "/index" do
        setup { get '/' }
        asserts_response_status 200
      end
    end

**COMING SOON:** Riot will look into test/riot\_macros, but not today.

#### Assertion macros

If you want to add special macros to an Assertion, this is as easy as adding them to a Context. Similar to Context macros, Assertion macros are included into the Assertion class.

For instance, let's say you wanted to add a macro for verifying that the result of an assertion is the same kind\_of object as you would expect. You would define the macro like so:

    module Custom
      module AssertionMacros
        def kind_of(expected_class)
          actual.kind_of?(expected) || failure("expected kind of #{expected}, not #{actual.inspect}")
        end
      end # AssertionMacros
    end # Custom
    Riot::Assertion.instance_eval { include Custom::AssertionMacros }

And in your context, you would use it like so:

    context "example" do
      asserts("a hash is defined") { {:foo => 'bar'} }.kind_of(Hash)
    end

Notice in the new macro we defined the use of the magical **actual** variable. `actual` is evaluated when the assertion is defined and made available to any Assertion macro. If you think you might want to chain assertions checks together, know that only the last failure will get recorded.

## TODO

TONS OF STUFF

1. Documentation about the `topic` method
1. Better documentation for everything
1. Refactor reporting; some abstracting is needed for recording a result (for instance)
1. Need to know where in backtrace a test failed (line number, etc.); i.e. backtrace filtering for clarity
1. More assertion macros: throws, etc.
1. Aliases for context "with, without, when, ..."; add those words to test description
1. Optimization and simplification (ex. flog is complaining print\_result\_stack)
1. Better error messages?
1. Perhaps: Multiple setup blocks in one context
1. Perhaps: association macro chaining
1. Perhaps: Uhhhhh ... a teardown method (only maybe. not sold :)

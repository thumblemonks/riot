# Riot

A fast, expressive and concise unit-testing framework.


## Installation 

Add Gemcutter to your gem sources:

    !!!plain
    sudo gem sources -a http://gemcutter.org

Then, simply install the Riot gem like so:

    !!!plain
    sudo gem install riot


## Usage

In contrast to other popular Ruby testing frameworks such as Test::Unit,
[Shoulda](http://github.com/thoughtbot/shoulda) and [RSpec](http://rspec.info/),
Riot does not run a `setup` and `teardown` sequence before and after each test. This speeds
up the test runs quite a bit, but also puts restrictions on how you write your tests. In
general, you should avoid mutating any objects under test.

In Riot, tests reside in *contexts*. Within these, a *topic* object is defined through a
`setup` block. The actual assertions are then made with `assert`.

    context "An Array" do
      setup { Array.new }
      asserts("is empty") { topic.empty? }
    end

As you can see, the setup block doesn't use any instance variables to save the object under
test -- rather, the return value of the block is used as the *topic*. This object can then
be accessed in the assertions using the `topic` attribute.

Furthermore, assertions need only return a boolean; `true` indicates a pass, while `false`
indicates a fail.

Contexts can also be nested; the `setup` blocks are executed outside-in before.

    context "An Array" do
      setup { Array.new }

      context "with one element" do
        setup { topic << "foo" }
        asserts("is not empty") { !topic.empty? }
        asserts("returns the element on #first") { topic.first == "foo" }
      end
    end


### Using assertion macros

Macros greatly simplify a lot of assertions by capturing common practises, e.g. comparing
some value using the `==` operator. They work by calling the macro method on the return
value of `asserts`:

    asserts("#first") { topic.first }.equals("foo")

Other macros are available; for a complete overview, see {Riot::AssertionMacro}.

A common pattern is to make assertions on the return value of some attribute or method
on the `topic` -- to simplify this, we have provided an easy to use shorthand. Simply
give a Symbol as the first argument to `asserts` and leave out the block.

    asserts(:first).equals("foo")


### Reading Riot's output

Riot can output the test results in several ways, the default being *story reporting*. With
this reporter, the output looks like the following:

    !!!plain
    An Array
      + asserts is empty
    An Array with one element
      + asserts is not empty
      + asserts returns the element on #first
    
    3 passes, 0 failures, 0 errors in 0.000181 seconds

The various shorthands and macros are built in a way that ensures expressive and specific
feedback, e.g. the assertion

    asserts(:full_name).matches(/^\w+ \w+$/)

yields the output

    !!!plain
    + asserts #full_name matches /^\w+ \w+$/


### Testing Rack application

Rack applications can easily be tested using [Riot::Rack](http://github.com/dasch/riot-rack),
which integrates [Rack::Test](http://github.com/brynary/rack-test) into Riot.

    require 'riot'
    require 'riot/rack'

    context "HelloWorldApp" do
      # Specify your app using the #app helper. If you don't specify
      # one, Riot::Rack will recursively look for a config.ru file.
      app { HelloWorldApp }

      # You can use all the Rack::Test helpers in the setup blocks.
      setup { get '/' }

      # You can access the response directly.
      asserts(:status).equals(200)
      asserts(:body).equals("Hello, World!")
    end


## Contributing

Riot is still in its infancy, so both the internal and external API may change radically.
That being said, we would love to hear any thoughts and ideas, and bug reports are always
welcome. We hang out in `#riot` on `irc.freenode.net`.

The code is hosted on [GitHub](http://github.com), and can be fetched with
[Git](http://git-scm.com) by running:

    !!!plain
    git clone git://github.com/thumblemonks/riot.git


## License

Riot is released under the MIT license. See {file:MIT-LICENSE}.

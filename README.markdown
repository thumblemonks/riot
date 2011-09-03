# Riot

A fast, expressive, and contextual ruby unit testing framework. Protest the slow test.

## Installation 

    gem install riot

## Usage

In contrast to other popular Ruby testing frameworks such as Test::Unit, [Shoulda](http://github.com/thoughtbot/shoulda) and [RSpec](http://rspec.info/), Riot does not run a `setup` and `teardown` sequence before and after each test. This speeds up test execution quite a bit, but also changes how you write your tests. In general and in my opinion, you should avoid mutating any objects under test and if you use Riot you're pretty much going to have to.

In Riot, tests reside in `contexts`. Within these, a `topic` object is defined through a `setup` block. The actual assertions are then made with an `asserts` or `denies` block.

```ruby
    context "An empty Array" do
      setup { Array.new }
      asserts("it is empty") { topic.empty? }
      denies("it has any elements") { topic.any? }
    end # An Array
```

As you can see, the setup block doesn't use any instance variables to save the object under test &mdash; rather, the return value of the block is used as the `topic`. This object can then be accessed in the assertions using the `topic` attribute. Furthermore, at their very basic level, assertions need only return a boolean. When using `asserts`, `true` indicates a pass while `false` indicates a fail; subsequently, when using `denies`, `true` indicates a failure whereas `false` indicates success.

Of course, you can nest contexts as well; the `setup` blocks are executed outside-in; as in, the parents' setups are run before the current context allowing for a setup hierarchy. `teardown` blocks are run inside out; the current context's teardowns are run before any of its parents'. This is what you would expect from other frameworks as well.

```ruby
    context "An Array" do
      setup { Array.new }

      asserts("is empty") { topic.empty? }

      context "with one element" do
        setup { topic << "foo" }
        asserts("array is not empty") { !topic.empty? }
        asserts("returns the element on #first") { topic.first == "foo" }
      end
    end # An Array
```

By the way, you can put any kind of ruby object in your context description. Riot will call `to_s` on the actual value before it is used in a reporting context. This fact will become [useful later](http://thumblemonks.github.com/riot/hacking.html#context-middleware) ;)

### Assertions {#assertions}

Well, how useful would Riot be if you could only return true/false from an assertion? Pretty useful, actually; but, we can make it more useful! No; that's not crazy. No it isn't. Yes; I'm sure.

We can do this with assertion macros. You can think of these as special assertion modifiers that check the return value of the assertion block. Actually, it's not that you **can** think of them this way; you **should** think of them this way.

Let's take this little for instance:

```ruby
    context "Yummy things" do
      setup { ["cookies", "donuts"] }

      asserts("#first") { topic.first }.equals("cookies")
    end # Yummy things
```

First, how's that for a readable test? Second, you should notice that the assertion block will return the `first` item from the `topic` (which is assumed to be `Enumerable` in this case); if it isn't `Enumerable`, then you have other problems. Since the first element in the array is "cookies", the assertion will pass. Yay!

But wait, there's more. Riot is about helping you write faster and more readable tests. Notice any duplication in the example above (besides the value "cookies")? I do. How about that `first` notation in the assertion name and reference in the assertion block. Riot provides a shortcut which allows you to reference methods on the topic through the assertion name. Here's another way to write the same test:

```ruby
    context "Yummy things" do
      setup { ["cookies", "donuts"] }

      asserts(:first).equals("cookies")
    end # Yummy things
```

Now that's real yummy. Want some more? Perhaps you just want to test the topic itself &mdash; not a method or attribute of it. You could do this:

```ruby
    context "Yummy things" do
      setup { ["cookies", "donuts"] }

      asserts("topic") { topic }.size(2)
    end # Yummy things
```

But, as you can probably already guess, that's gross and redundant. To solve this, Riot provides the `asserts_topic` shortcut which is a helper that pretty much just does `asserts("topic") { topic }` for you.

```ruby
    context "Yummy things" do
      setup { ["cookies", "donuts"] }

      asserts_topic.size(2)
    end # Yummy things
```

Yep, more readable.

#### Negative Assertions {#negative-assertions}

Way back in the first code example we saw a reference to `denies`; this is what is called the negative assertion. You could probably also call it a counter assertion, but I don't. You can use `denies` with any assertion macro that you can use `asserts` with; it's just that `denies` expects the assertion to fail for the test to pass. For instance:

```ruby
    context "My wallet" do
      setup do
        Wallet.new(1000) # That's 1000 cents, or $10USD yo
      end

      asserts(:enough_for_lunch?)
      denies(:enough_for_lunch?)
    end # My wallet
```

One of those will pass and the other will fail. If $10 is not enough for lunch the `denies` statement will pass; and then you should move to Chicago where it is enough (if only barely).

#### Built-in Assertion Macros {#builtin-macros}

There are a bunch of built-in assertion macros for your everyday use. Be sure to [write your own](http://thumblemonks.github.com/riot/hacking.html#writing-assertion-macros) if these don't satisfy your every need. You will notice the two varying mechanisms for passing arguments into the macros: one is the conventional form of message passing (via actual arguments) and the other is derived from a provided block. If the macro expects one argument, you can use either form (but not both). If the macro accepts multiple arguments, the last argument you want to pass in can be provided via the block.

The advantage of using the block is that its innards are evaluated against the same scope that the assertion was evaluated against. This means you can use the same helpers and instance variables in the macro block to generate an expected value (if you so desire). It's also useful if you have a fairly complex routine for generating the expected value.

{#builtin-macro-list}
* **Equals**: compares equality of the actual value to the expected value using the `==` operator 
  * `asserts.equals(Object)`
  * `denies.equals(Object)`
  * `asserts.equals { Object }`
  * `denies.equals { Object }`

* **Equivalent To**: compares equivalence of actual value to the expected value using the `===` operator
  * `asserts.equivalent_to(Object)`
  * `denies.equivalent_to(Object)`
  * `asserts.equivalent_to { Object }`
  * `denies.equivalent_to { Object }`

* **Assigns**: checks that the actual value has an instance variable defined within it's scope. You can also validate the value of that variable. Very much mimicing the `assigns` found in Rails-ish tests from way back in form, function, and need.
  * `asserts("a person") { Person.new }.assigns(:email)`
  * `denies("a person") { Person.new }.assigns(:email)`
  * `asserts("a person") { Person.new(:email => "a@b.com") }.assigns(:email, "a@b.com")`
  * `denies("a person") { Person.new(:email => "a@b.com") }.assigns(:email, "a@b.com")`
  * `asserts.assigns { :email }`
  * `denies.assigns { :email }`
  * `asserts.assigns(:email) { "a@b.com" }`
  * `denies.assigns(:email) { "a@b.com" }`

* **Nil**: simply checks the actual value for its nil-ness. Expects no arguments.
  * `asserts.nil`
  * `denies.nil`

* **Exists**: pretty much the opposite of the `nil` assertion macro. Expects no arguments.
  * `asserts.exists`
  * `denies.exists`

* **Matches**: compares the actual value to a provided regular expression
  * `asserts.matches(%r{Regex})`
  * `denies.matches(%r{Regex})`
  * `asserts.matches { /Regex/ }`
  * `denies.matches { /Regex/ }`

* **Raises**: validates the type of exception raised from the assertion block. Optionally, you can give it the message you expected in the form of a literal string or even a portion of it.
  * `asserts.raises(ExceptionClass)`
  * `denies.raises(ExceptionClass)`
  * `asserts.raises(ExceptionClass, "Expected message")`
  * `denies.raises(ExceptionClass, "Expected message")`
  * `asserts.raises(ExceptionClass) { "ted mess" }`
  * `denies.raises(ExceptionClass) { "ted mess" }`

* **Kind Of**: validates the type of object returned from the assertion block
  * `asserts.kind_of(Class)`
  * `denies.kind_of(Class)`
  * `asserts.kind_of { Class }`
  * `denies.kind_of { Class }`

* **Responds To**: checks that the actual object `respond_to?` to a particular message
  * `asserts.respond_to(:foo)`
  * `denies.respond_to(:foo)`
  * `asserts.respond_to { "foo" }`
  * `denies.respond_to { "foo" }`
  * `asserts.responds_to("foo")`
  * `denies.responds_to("foo")`
  * `asserts.responds_to { :foo }`
  * `denies.responds_to { :foo }`

* **Includes**: checks for the existence of: a character or sequence of characters in a string, an element in an array, or a key in a hash.
  * `asserts("this string") { "barbie q" }.includes("foo")`
  * `denies("this string") { "barbie q" }.includes("foo")`
  * `asserts("this array") { [1,2,3] }.includes(2)`
  * `denies("this array") { [1,2,3] }.includes(2)`
  * `asserts("this hash") { {:key1 => "foo"} }.includes(:key2)`
  * `denies("this hash") { {:key1 => "foo"} }.includes(:key2)`
  * `asserts.includes { "foo" }`
  * `denies.includes { "foo" }`
  * `asserts.includes { 2 }`
  * `denies.includes { 2 }`
  * `asserts.includes { :key }`
  * `denies.includes { :key }`

* **Size**: compares the size of the actual object to the number you provide. Works with anything that responds to `size(Numeric)` (strings, arrays, hashes, etc).
  * `asserts.size(Numeric)`
  * `denies.size(Numeric)`
  * `asserts.size { Numeric }`
  * `denies.size { Numeric }`

* **Any**: checks the result of calling `any?` on the actual value. Expects no arguments.
  * `asserts.any`
  * `denies.any`

* **Empty**: checks the result of calling `empty?` on the actual value. Expects no arguments.
  * `asserts.empty`
  * `denies.empty`

* **Same Elements**: compares actual to expected to see if they contain the same elements. Uses `Set` under-the-hood, just so you know.
  * `asserts.same_elements(Array)`
  * `denies.same_elements(Array)`
  * `asserts.same_elements { Array }`
  * `denies.same_elements { Array }`

### Setups, Hookups, and Helpers {#setups-hookups}

We're not even close to done yet; there's a lot more cool stuff for you to know about. You know about `setup` already; but you may not know that you can call `setup` multiple times within a Context. Well, you can. They run in the order you write them (top-down) and the result of a prior `setup` will be the `topic` for the next setup. In this way you **could** chain together some partitioned setup criteria without ever explicitly setting a variable (instance or local).

    context "A cheesey order" do
      setup { Cheese.create!(:name => "Blue") }
      setup { Order.create!(:cheese => topic, :purchase_order => "123-abc") }
  
      asserts_topic.kind_of(Order) # I love tests that are readable
    end # A cheesey order

This notion about a prior `setup` being the `topic` for a latter `setup` is true even when the `setup` is called from a parent Context.

More than likely, however, you'll want to modify something about the topic without changing what the topic for the context is. To do this, Riot provides the `hookup` block, which is just like a `setup` block except that `hookup` will always return the `topic` that was provided to it. It's kind of like calling `Object#tap`. Here's a for-instance:

```ruby
    context "A Person" do
      setup { Person.new(:name => "Master Blasterr") }

      denies(:valid?) # :(

      context "with valid email" do
        hookup { topic.email = "master@blast.err" }
        asserts(:valid?) # Yay!
      end # with valid email
    end # A complex thing
```

If the point didn't smack you in the face there, think about using `setup` instead of `hookup` in the sub-context. Had you written that as a `setup` block, you'd have to return `topic` after setting the email address, or else the new topic would be the actual email address; and you probably don't want to actually be calling `"master@blast.err".valid?` in the assertion.

You can also call `hookup` as many times as you like; the great part is that the `topic` never changes.

#### Helpers {#helpers}

You remember how you used to &mdash; or currently do &mdash; create instance variables to hold some data that you're going to use in your tests? Well, Riot allows you to still do that yucky stuff, but would rather you use a helper to encapsulate it. For instance, you could do this:

```ruby
    context "A greedy monkey" do
      setup do
        @a_ripe_banana = Banana.new(:ripe => true)
        Monkey.new
      end

      hookup { topic.takes(@a_ripe_banana) }

      asserts(:bananas).size(1)
    end # A greedy monkey
```

Or, you could do this

```ruby
    context "A greedy monkey" do
      helper(:a_ripe_banana) { Banana.new(:ripe => true) }
      setup { Monkey.new }

      hookup { topic.takes(a_ripe_banana) }

      asserts(:bananas).size(1)
    end # A greedy monkey
```

"So! What's the difference?", you ask. Nothing really. It's all aesthetic; but, it's a better aesthetic for a couple of reasons. Let me tell you why:

1. Helpers are good ways to encapsulate related setup data and give that data namespace
2. The act of setting up data does not clutter up your setups or assertions
3. I'll argue that it makes the code more readable; ex. how do you verbalize to your friends `@a_banana` and `a_banana`. In the former, I probably say "at a banana" and think "Why do I sound like a muppet when I talk?".
3. Being that helpers are blocks, you can actually pass arguments to them

What's that about (4)? Yes, helpers are really just over-glorified methods, which means you can pass arguments to them. Which means you can build factories with them. Which means those factories can go away when the context is no longer used and they're no longer cluttering up your object space. You want another for instance, eh?

```ruby
    context "A greedy monkey" do
      helper(:make_a_banana) do |color|
        Banana.new(:color => color)
      end

      setup { Monkey.new }

      hookup do
        topic.takes(make_a_banana("green"))
        topic.takes(make_a_banana("blue"))
      end

      asserts(:bananas).size(2)
      asserts("green bananas") { topic.bananas.green }.size(1)
      asserts("blue bananas") { topic.bananas.blue }.size(1)
    end # A greedy monkey
```

Or you could `make_many_bananas` or whatever. There are also lots of clever ways to get helpers included into a context which you will hopefully see when you read up on Context Middleware and look through the Recipes. Riot Rails makes liberal use of helpers when [setting up a context](http://github.com/thumblemonks/riot-rails/master/lib/riot/action_controller/context_middleware.rb) to test controllers.

Again, you define as many helpers as you like; you can also replace existing helpers by simply defining a helper with the same name (*that's because they're just methods defined within the context instance ... shhh*).

### Running Riot {#running}

Running your Riot tests is pretty simple. You can put your test files wherever you want, but it's generally a good idea to put them in a "test" directory. You can run individual test files using the normal ruby command:

    !!!plain
    ruby test/units/monkey_test.rb
    # or
    ruby -Itest test/units/monkey_test.rb

I like the latter and use it often. It means the test directory is loaded into the load path, which means I  don't have to be explicit about where to find my `teststrap.rb` file (which you might have named `test_helper.rb` in other projects even though it's a silly name). In your teststrap file you'll put all your common setup; maybe even including your Riot hacks. An out-of-the-box teststrap might look like this:

```ruby
    require 'rubygems'
    require '<my-library>'
    require 'riot'
```

Of course, you probably want to use rake to run your tests. Here's a basic Rakefile that will find our tests in the test directory or its subdirectories if the filename ends in `_test.rb`:

```ruby
    require 'rubygems'

    require 'rake'
    require 'rake/testtask'

    desc "Run all our tests"
    task :test do
      Rake::TestTask.new do |t|
        t.libs << "test"
        t.pattern = "test/**/*_test.rb"
        t.verbose = false
      end
    end

    task :default => :test
```

And then on the command line you simply run:

    !!!plain
    rake
    # or
    rake test

### Mocking {#mocking}

Mocking seems to be all the rage this decade. I try very hard to avoid it altogether through judicious use of anonymous classes, but sometimes you just need to mock. For Riot, [RR](http://github.com/btakita/rr) seemed to fit the bill nicely because it's:

* Lightweight
* Laid back
* Test framework agnostic and easy to integrate with
* Starts and ends with TWO R's!

That second to last point needs to be stressed a bit more. RR's default behavior is to not give a crap about what test framework you use. I can already hear you thinking, *"But wait, aren't you tying Riot to a mock framework?"*

Well, not really. Riot is mock framework agnostic; it'll work with any framework that can be worked with. Riot does not implicitly require in any RR support; you have to do that in your test-strapping.

However, there are a number of things you expect from a test framework when mocking is involved. Namely, if a mock expectation fails you want the context or assertion to fail, too. Additionally, you don't want to have to ask the mocking framework to validate itself for each assertion; you want Riot to do that for you. And some other things. So, Riot does most of the tedious mock-lifting for you and it suggests you use RR, but doesn't require it.

But enough of this hemming and hawing. What's it look like?! In your `teststrap.rb` you need to require in `riot/rr`:

```ruby
    # I'm teststrap.rb

    require 'rubygems'
    require 'riot/rr'
```

Then, in your tests, you use standard RR syntax for all of your mocking needs:

```ruby
    require 'teststrap.rb'

    context "A nice Person" do
      setup do
        Nice::Person.new
      end
  
      should("find a nice thing to say") do
        mock(topic).make_network_request { "Nice haircut" }
        topic.say_something_nice
      end.equals("Nice haircut")

    end # A nice Person
```

So, if `#say_something_nice` never calls `#make_network_request`, that assertion will fail for that reason first. If it does call `#make_network_request`, but for some reason "Nice haircut" is not returned, the tests will fail for that reason instead. It's like catching two birds with one test.

This is not an RR guide so you need to get familiar with it's syntax. Needless to say, if you require it in it's methods are available within any assertion, setup, teardown, hookup, and helper.

## Contributing

Riot is slowly solidifying its internal and external API. That being said, we would love to hear any thoughts and ideas, and bug reports are always welcome. We hang out in `#riot` on `irc.freenode.net`.

Source code is hosted on [GitHub](http://github.com), and can be fetched with
[Git](http://git-scm.com) by running:

    !!!plain
    git clone git://github.com/thumblemonks/riot.git

If you want to make changes, please feel free to do so. The best process is to fork, fix, and send a pull request.

## License

Riot is released under the MIT license. See [MIT LICENSE](https://github.com/thumblemonks/riot/blob/master/MIT-LICENSE). 

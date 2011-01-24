---
title: Ruby Testing Framework
description: An extremely fast-running, expressive, and context-driven unit testing framework. Protest the slow test.
keywords: ruby, testing, framework, riot
layout: default
---

## News

*See if we can pull RSS or something from [rubygems.org/riot](http://rubygems.org/gem/riot) and the spin-off/extensions projects.*

## Getting Started {#getting-started}

I want to get this out of the way right now, in contrast to other popular Ruby testing frameworks such as Test::Unit, [Shoulda](http://github.com/thoughtbot/shoulda) and [RSpec](http://rspec.info/), Riot does not run a `setup` and `teardown` sequence before and after each test [^why]. This speeds up test execution quite a bit, but also changes how you write your tests. In general and in my opinion, you should avoid mutating any objects under test and if you use Riot you're pretty much going to have to.

In Riot, tests reside in `contexts`. Within these, a `topic` object is defined through a `setup` block. The actual assertions are then made with an `asserts` or `denies` block.

{% highlight ruby %}
context "An empty Array" do
  setup { Array.new }
  asserts("it is empty") { topic.empty? }
  denies("it has any elements") { topic.any? }
end # An Array
{% endhighlight %}

As you can see, the setup block doesn't use any instance variables to save the object under test &mdash; rather, the return value of the block is used as the `topic`. This object can then be accessed in the assertions using the `topic` attribute. Furthermore, at their very basic level, assertions need only return a boolean. When using `asserts`, `true` indicates a pass while `false` indicates a fail; subsequently, when using `denies`, `true` indicates a failure whereas `false` indicates success.

Of course, you can nest contexts as well; the `setup` blocks are executed outside-in; as in, the parents' setups are run before the current context allowing for a setup hierarchy. `teardown` blocks are run inside out; the current context's teardowns are run before any of its parents'. This is what you would expect from other frameworks as well.

{% highlight ruby %}
context "An Array" do
  setup { Array.new }

  asserts("is empty") { topic.empty? }

  context "with one element" do
    setup { topic << "foo" }
    asserts("array is not empty") { !topic.empty? }
    asserts("returns the element on #first") { topic.first == "foo" }
  end
end # An Array
{% endhighlight %}

By the way, you can put any kind of ruby object in your context description. Riot will call `to_s` on the actual value before it is used in a reporting context. This fact will become [useful later](./hacking.html#context-middleware) ;)

### Assertions {#assertions}

Well, how useful would Riot be if you could only return true/false from an assertion? Pretty useful, actually; but, we can make it more useful! No; that's not crazy. No it isn't. Yes; I'm sure.

We can do this with assertion macros. You can think of these as special assertion modifiers that check the return value of the assertion block. Actually, it's not that you **can** think of them this way; you **should** think of them this way.

Let's take this little for instance:

{% highlight ruby %}
context "Yummie things" do
  setup { ["cookies", "donuts"] }
  asserts("#first") { topic.first }.equals("cookies")
end # Yummie things
{% endhighlight %}

First, how's that for a readable test? Second, you should notice that the assertion block will return the `first` item from the `topic` (which is assumed to be `Enumerable` in this case); if it isn't `Enumerable`, then you have other problems. Since the first element in the array is "cookies", the assertion will pass. Yay!

But wait, there's more. Riot is about helping you write faster and more readable tests. Notice any duplication in the example above (besides the value "cookies")? I do. How about that `first` notation in the assertion name and reference in the assertion block. Riot provides a shortcut which allows you to reference methods on the topic through the assertion name. Here's another way to write the same test:

{% highlight ruby %}
context "Yummie things" do
  setup { ["cookies", "donuts"] }
  asserts(:first).equals("cookies")
end # Yummie things
{% endhighlight %}

Now that's real yummie.

There are a bunch of built-in assertion macros and you can even [write your own](./hacking.html#writing-assertion-macros)

* equals
* ...

#### Negative Assertions {#negative-assertions}

Way back in the first code example we saw a reference to `denies`; this is what is called the negative assertion. You could probably also call it a counter assertion, but I don't. You can use `denies` with any assertion macro that you can use `asserts` with; it's just that `denies` expects the assertion to fail for the test to pass. For instance:

{% highlight ruby %}
context "My wallet" do
  setup do
    Wallet.new(1000) # That's 1000 cents, or $10USD yo
  end

  asserts(:enough_for_lunch?)
  denies(:enough_for_lunch?)
end # My wallet
{% endhighlight %}

One of those will pass and the other will fail. If $10 is not enough for lunch the `denies` statement will pass; and then you should move to Chicago where it is enough (if only barely).

### Setups, Hookups, and Helpers {#setups-hookups}

We're not even close to done yet; there's a lot more cool stuff for you to know about. You know about `setup` already; but you may not know that you can call `setup` multiple times within a Context. Well, you can. They run in the order you write them (top-down) and the result of a prior `setup` will be the `topic` for the next setup. In this way you **could** chain together some partitioned setup criteria without ever explicitly setting a variable (instance or local).

{% highlight ruby %}
context "A cheesey order" do
  setup { Cheese.create!(:name => "Blue") }
  setup { Order.create!(:cheese => topic, :purchase_order => "123-abc") }
  
  asserts_topic.kind_of(Order) # I love tests that are readable
end # A cheesey order
{% endhighlight %}

This notion about a prior `setup` being the `topic` for a latter `setup` is true even when the `setup` is called from a parent Context.

More than likely, however, you'll want to modify something about the topic without changing what the topic for the context is. To do this, Riot provides the `hookup` block, which is just like a `setup` block except that `hookup` will always return the `topic` that was provided to it. It's kind of like calling `Object#tap`. Here's a for-instance:

{% highlight ruby %}
context "A Person" do
  setup { Person.new(:name => "Master Blasterr") }

  denies(:valid?) # :(

  context "with valid email" do
    hookup { topic.email = "master@blast.err" }
    asserts(:valid?) # Yay!
  end # with valid email
end # A complex thing
{% endhighlight %}

If the point didn't smack you in the face there, think about using `setup` instead of `hookup` in the sub-context. Had you written that as a `setup` block, you'd have to return `topic` after setting the email address, or else the new topic would be the actual email address; and you probably don't want to actually be calling `"master@blast.err".valid?` in the assertion.

You can also call `hookup` as many times as you like; the great part is that the `topic` never changes.

#### Helpers {#helpers}

You remember how you used to &mdash; or currently do &mdash; create instance variables to hold some data that you're going to use in your tests? Well, Riot allows you to still do that yucky stuff, but would rather you use a helper to encapsulate it. For instance, you could do this:

{% highlight ruby %}
context "A greedy monkey" do
  setup do
    @a_ripe_banana = Banana.new(:ripe => true)
    Monkey.new
  end

  hookup { topic.takes(@a_ripe_banana) }

  asserts(:bananas).size(1)
end # A greedy monkey
{% endhighlight %}

Or, you could do this

{% highlight ruby %}
context "A greedy monkey" do
  helper(:a_ripe_banana) { Banana.new(:ripe => true) }
  setup { Monkey.new }

  hookup { topic.takes(a_ripe_banana) }

  asserts(:bananas).size(1)
end # A greedy monkey
{% endhighlight %}

"So! What's the difference?", you ask. Nothing really. It's all aesthetic; but, it's a better aesthetic for a couple of reasons. Let me tell you why:

1. Helpers are good ways to encapsulate related setup data and give that data namespace
2. The act of setting up data does not clutter up your setups or assertions
3. I'll argue that it makes the code more readable; ex. how do you verbalize to your friends `@a_banana` and `a_banana`. In the former, I probably say "at a banana" and think "Why do I sound like a muppet when I talk?".
3. Being that helpers are blocks, you can actually pass arguments to them

What's that about (4)? Yes, helpers are really just over-glorified methods, which means you can pass arguments to them. Which means you can build factories with them. Which means those factories can go away when the context is no longer used and they're no longer cluttering up your object space. You want another for instance, eh?

{% highlight ruby %}
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
{% endhighlight %}

Or you could `make_many_bananas` or whatever. There are also lots of clever ways to get helpers included into a context which you will hopefully see when you read up on Context Middleware and look through the Recipes. Riot Rails makes liberal use of helpers when [setting up a context](http://github.com/thumblemonks/riot-rails/master/lib/riot/action_controller/context_middleware.rb) to test controllers.

Again, you define as many helpers as you like; you can also replace existing helpers by simply defining a helper with the same name (*that's because they're just methods defined within the context instance ... shhh*).

### Running Riot {#running}

Running your Riot tests is pretty simple. You can put your test files wherever you want, but it's generally a good idea to put them in a "test" directory. You can run individual test files using the normal ruby command:

    ruby test/units/monkey_test.rb
    # or
    ruby -Itest test/units/monkey_test.rb

I like the latter and use it often. It means the test directory is loaded into the load path, which means I  don't have to be explicit about where to find my `teststrap.rb` file (which you might have named `test_helper.rb` in other projects even though it's a silly name). In your teststrap file you'll put all your common setup; maybe even including your Riot hacks. An out-of-the-box teststrap might look like this:

{% highlight ruby %}
require 'rubygems'
require '<my-library>'
require 'riot'
{% endhighlight %}

Of course, you probably want to use rake to run your tests. Here's a basic Rakefile that will find our tests in the test directory or its subdirectories if the filename ends in `_test.rb`:

{% highlight ruby %}
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
{% endhighlight %}

And then on the command line you simply run:

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

{% highlight ruby %}
# I'm teststrap.rb

require 'rubygems'
require 'riot/rr'
{% endhighlight %}

Then, in your tests, you use standard RR syntax for all of your mocking needs:

require 'teststrap.rb'

{% highlight ruby %}
context "A nice Person" do
  setup do
    Nice::Person.new
  end
  
  should("find a nice thing to say") do
    mock(topic).make_network_request { "Nice haircut" }
    topic.say_something_nice
  end.equals("Nice haircut")

end # A nice Person
{% endhighlight %}

So, if `#say_something_nice` never calls `#make_network_request`, that assertion will fail for that reason first. If it does call `#make_network_request`, but for some reason "Nice haircut" is not returned, the tests will fail for that reason instead. It's like catching two birds with one test.

This is not an RR guide so you need to get familiar with it's syntax. Needless to say, if you require it in it's methods are available within any assertion, setup, teardown, hookup, and helper.

<!-- Footnotes -->

[^why]: I wrote Riot specifically not to run setups and teardowns around each assertion. I did this because in practice, I rarely mutated my object under test and I much preferred an efficient testing framework.
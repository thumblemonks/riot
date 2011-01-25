---
title: Hacking with Riot
description: Thing developers should know about extending Riot for their projects or libraries
keywords: ruby, testing, framework, riot, hacking
layout: section
---

## Hacking Riot

You are the Hack King. You want to succeed. When I say that, I mean it in all sincerity about you. If you didn't want to succeed, you wouldn't be looking at Riot. Ohhh! I said it.

As a co-worker once said to me, *"You Ruby developers always come out with both fists punching."* I couldn't agree more.

Want to know something I don't like? Yes, you do. I don't like being annoyed by my test framework when I go to extend it. Testing frameworks should not be closed systems; and while Ruby makes it easy to keep code open, code can still be closed from a conceptual standpoint.

What does that mean for you? It means Riot wants to be open. It wants you to make it better with your own little do-dads, knick-knacks, code cubbies, and under-the-hood rock'em robots. Riot wants you to do it just for you or if you feel so inclined, do it for everyone by contributing back. Before you can do that, however, there are probably a few things you should know about how Riot works.

### Let's Start at the Beginning {#beginning-hacking}

When you define a context in your test code, Riot will create a `Riot::Context` object (Context), tell it what you wanted the description to be, and push it onto the queue of contexts it knows about. This is boring so far, I know. When you define a sub-context (a context within a context), Riot does the same as before except that it tells this new context who its parent context is. The context tree is essentially flattened out in Riot's "mind" at this point. Riot just has one big list. Though I did play around with a true tree structure, this way allows for some better abstractions of responsibility. As a context, this bit about knowing the parent means a sub-context can "inherit" setups, teardowns, hookups, and helpers; and the linked-list approach still maintains a tree structure since a child knows only of its immediate parent.

When a context is added to the list of runnable contexts, its innards are also evaluated in order to prepare/generate the actual setups, teardowns, hookups, helpers, and assertions. These are managed by the containing context only. When all of the contexts have been evaluated &mdash; which happens at run-time as the classpath is getting loaded in &mdash; Riot will run through the list of contexts in the order in which they were defined. When an assertion is executed, its result is immediately reported.

Something special about Riot and assertions is that Riot creates a unique Situation for each context. The job of the situation is to be an evaluation instance for that context; or a data "jail" for the life of the context. Things like `topic` or instance variables exist only while the situation lasts. Anything that happens within a helper, setup, assertion, etc. are all evaluated against the situation. This should mean that contexts don't inadvertently use/collide-with each others' data. The situation is then thrown away when the context is finished. Thusly, make sure to not assign a situation instance to a long-lasting variable and do not assign variables in situations to things outside of it; the GC monster will eat you when next you sleep.

### Writing Your Own Assertion Macros {#writing-assertion-macros}

Remember that `equals` assertion macro from the [Daily Use](/) page? Well, it's an Assertion Macro and is just like something you could write. I mean that for real; it's not hard at all. For instance, here is the full assertion macro for `equals`:

{% highlight ruby %}
module Riot
  class EqualsMacro < AssertionMacro
    register :equals

    def evaluate(actual, expected)
      if expected == actual
        pass new_message.is_equal_to(expected)
      else
        fail expected_message(expected).not(actual)
      end
    end

    def devaluate(actual, expected)
      if expected != actual
        pass new_message.is_equal_to(expected).when_it_is(actual)
      else
        fail new_message.did_not_expect(actual)
      end
    end
  end # EqualsMacro
end # Riot
{% endhighlight %}

Before we break that down, here's a list of six keywords you should see in any macro you write: `AssertionMacro`, `register`, `evaluate`, `devaluate`, `pass`, `fail`. If you don't see one or some of them, that better be because you are extending/mixing-in functionality that is using that keyword.

One, `Riot::AssertionMacro` is required because it has the awesome functionality you need for your macro to execute and report its findings.

Two, `register` is a class helper that actually tells Riot how to tie your usage of `equals` at the end of an assertion to some assertion checking logic (this macro). It's not important whether or not you use a symbol or a string, but it should definitely be something that would match a valid method name. You should also know that if someone else defines a macro with the same name after yours has been registered, their's will win; there can be only one.

Three, `evaluate` is what you will implement to satisfy the `asserts` assertions. In regards to `equals`, we only care about the actual value (what was returned by the assertion block the user wrote) and what is expected.

Four, `devaluate` is what you will implement to support the `denies` assertion. In this case, the assertion passes if the actual string DOES NOT match the expected one.

Finally, `pass` and `fail` are helper methods which simply return a tuple. To be truthful, you can return whatever you want so long as Riot can do something with it. The current format is `[status, 'message']` where `status` is one of the following values `:pass`, `:fail`, and `:error`.

*"But, what about that interesting looking message chain thing: `expected_message(expected).not(actual)`?"*, you note.

#### Messages {#messages}

Messages are a wondrous bundle of joy is all I can say. I got tired of writing strings with interpolated other strings and being all verbose; so I devised a way to let me mostly use english to construct sentences that also take variable values[^speed]. Let's take a for instance; the message string you so wisely pointed out above would produce the following should the values of `expected` and `actual` be "goobers" and "nerds" respectively:

    "expected 'goobers', not 'nerds'"

And that other string, `new_message.is_equal_to(expected)` would produce:

    "is equal to 'goobers'"
    
`new_message` simply creates a new Message instance. Whereas `expected_message` starts a new Message instance, but prefaces it with "expected"; it's the same as typing `new_message.expected(expected)`. You may also say `should_have_message(expected).not(actual)` to produce:

    "should have 'goobers', not 'nerds'"

You may only use these three helpers from within an assertion macro, but you can use `Riot::Message` anywhere you want. What you can expect from Message is:

* that any method call &mdash; eg. `is_equal_to` &mdash; will have its name converted to a string and underscores replaced with spaces
* that any arguments passed to a method call &mdash; eg. `is_equal_to("mommy")` &mdash; will be inspected using `Object#inspect` and have those values appended to the overall message
* using the method named `comma` will append a ","
* using the method named `not` will append a ", not"
* using the method named `but` will append a ", but"

What this means is that you can use Message to generate nice output from your macros, but again you do not have to. You could simply return any string you want.

#### Arguments passed to macros {#macro-arguments}

It's not going to be obvious how arguments passed to `evaluate` and `devaluate` are handled just by looking at the `equals` macro. In that specific macro you see `actual` as the first argument and `expected` as the second. By convention, the actual value returned from evaluating the assertion block (the block the user wrote) will always be the first argument to your macros evaluation method. Beyond that, you can expect as many arguments as your macro needs (explicitly or implicitly using splat).

Here, the `equals` macro is saying that it only wants one argument to use in comparison with the actual value. `raises` on the other hand, lets you pass up to two arguments with the second being the optional exception message that is expected.

{% highlight ruby %}
context "Making problems"
  setup do
    Exception.new("Take this!")
  end

  asserts("exception type alone") { raise topic }.raises(Exception)
  asserts("exception type and message") { raise topic }.raises(Exception, "Take this!")
end # Making problems
{% endhighlight %}

It's also possible that an evaluation block be passed to your macro. For instance:

{% highlight ruby %}
context "Making jelly" do
  setup { BlueBerry.new }

  asserts(:color).equals("red")
  asserts(:color).equals { "red" }
end # Making jelly
{% endhighlight %}

Both of the assertions will have the same result and you never need to care that the expected value was provided via evaluating a block. By convention Riot notices this, evaluates it, and passes the returned value from the block into the/your macro as the last argument ... always. This means that if you were writing a macro named `awesomeness` and the following was its usage in practice:

{% highlight ruby %}
context "Jambonee" do
  topic { Song.new("Jambonee") }
  
  asserts_topic.awesomeness(11) { Scale.new(11) }
end # Jambonee
{% endhighlight %}

Then your `evaluate` and `devaluate` methods need to accept two arguments in addition to the always present `actual` argument. Like so:

{% highlight ruby %}
class AwesomenessMacro < Riot::AssertionMacro
  register :awesomeness
  
  def evaluate(actual, expected_awesomeness, scale)
    # ...
  end

  def devaluate(actual, unexpected_awesomeness, scale)
    # ...
  end
end # AwesomenessMacro
{% endhighlight %}

If you want `scale` to be optional, you can default it to whatever you want. This is Ruby!

#### Working with errors in your macros {#working-with-errors}

Normally, you can ignore errors in your assertion macro because Riot specifically handles them when they are raised. However, if you're intending to write an assertion macro that cares about errors you can do so easily as you are registering it. To declare that your macro expects exceptions, you simply call `expects_exception!`. For instance:

{% highlight ruby %}
module Riot
  class RaisesMacro < AssertionMacro
    register :raises
    expects_exception!
    
    # ...
  end # RaisesMacro
end # Riot
{% endhighlight %}

That is the actual opening stanza to Riot's own `raises` macro. What happens when you register your macro in this way is that Riot will pass the actual exception on to your macro if one is raised while evaluating the assertion block (your macro will be called by default if no exception is raised). The exception itself will be the the first argument passed to `evaluate` or `devaluate` or `nil` in the event nothing was raised.

#### Why would you write your own macro?

You'll probably want to write your own macro if:

* You're writing Riot support for your fancy framework. I bet your framework has a DSL and it'd be nice if users could mimic that DSL in their Riot tests.
* You've noticed a lot of repetitive or tedious logic in your assertion blocks
* It's just fun

Riot implements but a handful of general checks most people expect and actually use. But, that's not to say it's complete. The joy of Riot is being concise and elegant and macros are how that happens.

### Context Middleware {#context-middleware}

By now you're probably asking yourself, "How could Riot get any better?" How about we get jiggy one level above assertions? I'm talking Context Middleware and this is where things might get a little abstract.

Perhaps all you've known of Riot is what you've read in this documentation (except this section). Perhaps you're a whiz at Riot and you're all up in it writing macros and what not. Now, perhaps you've gotten to the point where you'd like to do something extra fancy and write some helpful setup blocks that are only injected if the context's description is a specific type of class (not just a string).

{% highlight ruby %}
context Person do
  denies(:valid?)
end # Person
{% endhighlight %}

Perhaps now you're bummed. But, don't be! Context middleware can help. We can actually make that a valid Riot context and test by writing this small snippet of code:

{% highlight ruby %}
class Modelware < Riot::ContextMiddleware
  register
  
  def call(context)
    if context.description.kind_of?(Model)
      context.setup { context.description.new }
    end
    middleware.call(context)
  end
end # Modelware
{% endhighlight %}

*"Get the %\*@& out of here!"*, you say.

I know! It's pretty awesome and it's pretty powerful. If you're familiar at all with the nature of Rack middleware &mdash; how to implement it, how it's executed, etc. &mdash; you'll be familiar with Context middleware as the principles are similar:

1. Define a class that extends `Riot::ContextMiddleware`
2. Call `register`
3. Implement a `call` method that accepts the Context that is about to be executed
4. Do stuff, but make sure to pass the call along with `middleware.call(context)`

Steps 1, 2, and 3 should be pretty straight-forward. Currently, `context` is the only argument to `call`. When your middleware is initialized it is given the next registered middleware in the chain (which is where the `middleware` method gets its value from).

So, "Do stuff" from step 4 is the where we start breaking things down. What can you actually do? Well, you can do anything to the context that you could do if you were writing a Riot test; and I do mean anything.

* Add setup blocks (as many as you like)
* Add teardown blocks (as many as you like)
* Add hookup blocks (as many as you like)
* Add helpers (as many as you like)
* Add assertions

The context in question will not run before all middleware have been applied to the context; this is different behavior than that of Rack middleware. Context middleware is only about preparing a context, not about executing it. Thus, where in your method you actually pass the call off to the next middleware in the chain has impact on how the context is set up. Basically, whatever you do before calling `middleware.call(context)` is done before any other middleware gets setup and before the innards of the context itself are applied. Whatever you do after that call is done after all that, but still before the actual setups, hookups, assertions, and teardowns are run.

In effect, the only[^please] way you could futz with the execution of the context would be to not call `middleware.call(context)`.

#### What if I want my setup to be first? {#primary-setup}

If you know you'd like your setup to go first, regardless of where in the middleware call chain you are, you simply need to pass `true` as the first argument to it. For instance:

{% highlight ruby %}
class Bloatware < Riot::ContextMiddleware
  register

  def call(context)
    middleware.call(context)
    context.setup(true) do
      puts "Ha ha, I'm not doing anything important"
    end
  end
end # Bloatware
{% endhighlight %}

This will make Bloatware's setup run before any other setup in the given context, but not before the setups from parent contexts. Additionally, if Bloatware was called from some other middleware that middleware could get its setup in before Bloatware's. Generally, you should avoid needing to worry about order.

#### Contextual Options {#context-options}

While re-doing Riot Rails for about the 12th time I stumbled onto the idea of Context Middleware. That was great, but while working through some middleware I realized I wanted to be able to configure that middleware from within a running context. Specifically, I wanted to be able to be make a context transactional (similar to how you can with the Test::Unit implementation) by "flipping a switch". By being transactional, any database changes would be rolled back when the context was finished.

A theoretical example of usage:

{% highlight ruby %}
context Room do
  set :transactional, true
  
  hookup { topic.create! }
  denies(:new_record?)
end # Room
{% endhighlight %}

So, `set` ... that's the new thing and it takes two arguments: a key and a value. Now, how is it used?


{% highlight ruby %}
module RiotRails
  class TransactionalMiddleware < Riot::ContextMiddleware
    register

    def call(context)
      middleware.call(context)
      make_transactional(context) if want_transactional?(context)
    end
  private
    def want_transactional?(context)
      context.option(:transactional) == true
    end

    def make_transactional(context)
      # The guts and glory
    end

  end # TransactionalMiddleware
end # RiotRails
{% endhighlight %}

I removed the distracting code so you can see that `context.option(:transactional)` is used in `want_transactional?`. You should also notice that we are inspecting the option after the middleware chain has been processed. This is important as you won't see any options before you pass the call on.

`set` is just a basic DSL around a hash; very similar to `set` in Sinatra; in fact, that's why it's named that way here. If, for some reason, you need direct access to the hash options, you can say `context.options`. Finally, there is no limit[^dwi] placed on the number of options that can be set.

<!-- footnotes -->

[^speed]: The implementation of Message is actually really fast. It's even benchmarked.
[^please]: Clearly it's not the only way, but if you're being a good samaritan it is.
[^dwi]: Yes, yes, yes. There is an actual limit, but not one that Riot worries about. 
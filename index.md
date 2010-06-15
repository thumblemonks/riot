---
title: Ruby Testing Framework
description: An extremely fast-running, expressive, and context-driven unit testing framework. Protest the slow test.
keywords: ruby, testing, framework, riot
layout: default
---

## News

*See if we can pull RSS or something from [rubygems.org/riot](http://rubygems.org/gem/riot) and the spin-off/extensions projects.*

## Getting Started

In contrast to other popular Ruby testing frameworks such as Test::Unit, [Shoulda](http://github.com/thoughtbot/shoulda) and [RSpec](http://rspec.info/), Riot does not run a `setup` and `teardown` sequence before and after each test. This speeds up the test runs quite a bit, but also puts restrictions on how you write your tests. In general, you should avoid mutating any objects under test.

In Riot, tests reside in `contexts`. Within these, a `topic` object is defined through a `setup` block. The actual assertions are then made with an `assert` block.

    context "An Array" do
      setup { Array.new }
      asserts("is empty") { topic.empty? }
    end # An Array

As you can see, the setup block doesn't use any instance variables to save the object under test -- rather, the return value of the block is used as the `topic`. This object can then be accessed in the assertions using the `topic` attribute. Furthermore, at their very basic level, assertions need only return a boolean; `true` indicates a pass, while `false` indicates a fail.

Of course, you can nest contexts as well; the `setup` blocks are executed outside-in; as in, the parents' setups are run before the current context allowing for a setup hierarchy; this is also what you would expect from other frameworks.

    context "An Array" do
      setup { Array.new }

      context "with one element" do
        setup { topic << "foo" }
        asserts("array is not empty") { !topic.empty? }
        asserts("returns the element on #first") { topic.first == "foo" }
      end
    end # An Array

By the way, you can put use any kind of ruby object in your context description. Riot will call `to_s` on the actual value before it is used in a reporting context. This fact will become useful later ;)

### Assertion Macros

Well, how useful would Riot be if you could only return true/false from an assertion? Pretty useful, actually; but, we can make it more useful! No; that's not crazy. No it isn't. Yes; I'm sure.

We can do this with assertion macros. You can think of these as special assertion modifiers that check the return value of the assertion block. Actually, it's not that you **can** think of them this way; you **should** think of them this way.

Let's take this little for instance:

    context "Yum" do
      setup { ["cookies", "donuts"] }
      asserts("#first") { topic.first }.equals("cookies")
    end # Yum

First, how's that for a readable test? Second, you should notice that the assertion block will return the `first` item in from the `topic`, which is assumed to be `Enumerable`. If it isn't, then you have other problems. Since the first element in the array is "cookies", the assertion will pass. Yay!

But wait, there's more. Riot is about helping you write tests faster and to be more readable. Notice any duplication in the example above (besides the value "cookies")? I do. How about that `first` notation in the assertion name and reference in the assertion block. Riot provides a shortcut which allows you reference methods on the topic through the assertion name. Here's another way to write the same test:

    context "Yum" do
      setup { ["cookies", "donuts"] }
      asserts(:first).equals("cookies")
    end # Yum

Now that real yum.

There are a bunch of [built-in assertion macros](). Elsewhere, we'll explain to you how to write your own.

### Setups, Hookups, and Helpers

We're not done yet; there's plenty more cool stuff for you to know about. You know about `setup` already; but you may not know that you can call `setup` multiple times within a Context. Well, you can. They run in the order you write them (top-down) and the result of a prior `setup` will be the `topic` for the next setup. in this way you *could* chain together some partitioned setup criteria without ever explicitly setting a variable (instance or local).

    context "A cheesey order" do
      setup { Cheese.create!(:name => "Blue") }
      setup { Order.create!(:cheese => topic, :purchase_order => "123-abc") }
      
      asserts_topic.kind_of(Order) # I love tests that are readable
    end # A cheesey order

This notion about a prior `setup` being the `topic` for a latter `setup` is true even when the `setup` is called from a parent Context.

More than likely, however, you'll want to modify something about the topic without changing what the topic for the context is. To do this, Riot provides the `hookup` block, which is just like a `setup` block except that `hookup` will always return the `topic` that was provided to it. It's kind of like calling `Object#tap`. Here's a for-instance:

    context "A Person" do
      setup { Person.new(:name => "Master Blasterr") }

      asserts(:valid?).not!

      context "with valid email" do
        hookup { topic.email = "master@blast.err" }
        asserts(:valid?) # Yay!
      end # with valid email
    end # A complex thing

You can also `hookup` as many times as you like; the great part is that the `topic` never changes.

### The Situation

### Context Middleware

By now you're probably asking yourself, "How could Riot get any better?"

### Writing Your Own Assertion Macros

### Mocking

* rr

## Riot and Frameworks

### Sinatra

* chicago

### Rails

* riot-rails

### Mongoid

* riot-mongoid

## Common Recipes

### Adding context helpers methods

### Lazy-loaded helpers

    helper(:foo) { @foo ||= Foo.new }

## Oddities

* Riot.dots
* WVSI96

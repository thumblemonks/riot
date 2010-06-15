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
    end

As you can see, the setup block doesn't use any instance variables to save the object under test -- rather, the return value of the block is used as the `topic`. This object can then be accessed in the assertions using the `topic` attribute. Furthermore, assertions need only return a boolean; `true` indicates a pass, while `false` indicates a fail.

Of course, you can nest contexts as well; the `setup` blocks are executed outside-in; as in, the parents' setups are run before the current context allowing for a setup hierarchy; this is also what you would expect from other frameworks.

    context "An Array" do
      setup { Array.new }

      context "with one element" do
        setup { topic << "foo" }
        asserts("is not empty") { !topic.empty? }
        asserts("returns the element on #first") { topic.first == "foo" }
      end
    end

### Contexts

### Assertions and Macros

### Setups, Hookups, and Helpers

### Writing Your Own Macros

### The Situation

### Context Middleware

## Riot and Frameworks

### Sinatra

### Rails

## Common Recipes

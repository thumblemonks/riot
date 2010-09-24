---
title: Hacking with Riot
description: Thing developers should know about extending Riot for their projects or libraries
keywords: ruby, testing, framework, riot, hacking
layout: default
---

## Hacking Riot

You are the Hack King. You want to succeed. When I say that, I mean it in all sincerity about you. If you didn't want to succeed, you wouldn't be looking at Riot. Ohhh! I said it.

As a co-worker once said to me, *"You Ruby developers always come out with both fists punching."* I couldn't agree more.

Want to know something I don't like? Yes, you do. I don't like being annoyed by my test framework when I go to extend it. Testing frameworks should not be closed systems; and while Ruby makes it easy to keep code open, code can still be closed from a conceptual standpoint.

What does that mean for you? It means Riot wants to be open. It wants you to make it better with your own little do-dads, knick-knacks, code cubbies, and under-the-hood rock'em robots. Riot wants you to do it just for you or if you feel so inclined, do it for everyone by contributing back. Before you can do that, however, there are probably a few things you should know about how Riot works.

### Let's Start at the Beginning

When you define a context in your test code, Riot will create a `Riot::Context` object (Context), tell it what you wanted the description to be, and push it onto the queue of contexts it knows about. This is boring so far, I know. When you define a sub-context (a context within a context), Riot does the same as before except that it tells this new context who its parent context is. The context tree is essentially flattened out in Riot's "mind" at this point. Riot just has one big list, though I did play around with the notion of only knowing top-level contexts. This way makes for some better abstractions of responsibility. As a context, this bit about knowing the parent means a sub-context can "inherit" setups, teardowns, hookups, and helpers.

When a context is added to the list of runnable contexts, its innards are also evaluated in order to prepare/generate the actual setups, teardowns, hookups, helpers, and assertions. These are managed by the containing context only. When all of the contexts have been evaluated - which happens at run-time as the classpath is getting loaded in - Riot will run through the list of contexts in the order in which they were defined. When an assertion is executed, its result is immediately reported.

Something special about Riot and assertions is that Riot creates a unique Situation for each context. The job of the situation is to be an evaluation instance for that context; or a data "jail" for the life of the context. Things like `topic` or instance variables exist only while the situation lasts. Anything that happens within a helper, setup, assertion, etc. are all evaluated against the situation. This should mean that contexts don't inadvertently use/collide-with each others' data. The situation is then thrown away when the context is finished.

### Writing Your Own Assertion Macros

Remember that `equals` assertion macro from the [Daily Use](/) page? Well, it's an Assertion Macro and is just like something you could write. I mean that for real; it's not hard at all. For instance, here is the full assertion macro for `equals`:

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
      end
    end

Before we break that down, here's a list of five keywords you should see any macro you write: `AssertionMacro`, `register`, `evaluate`, `pass`, `fail`. If you don't see one or some of them, that better be because you are extending/mixing-in functionality that is using that keyword.

One, `Riot::AssertionMacro` is required because it has the awesome functionality you need for your macro to execute and report its findings.

Two, `register` is a class helper that actually tells Riot how to tie your usage of `equals` at the end of an assertion to some assertion checking logic (this macro). It's not important whether or not you use a symbol or a string, but it should definitely be something that would match a valid method name. You should also know that if someone else defines a macro with the same name after yours has registered, their's will win; there can be only one.

Three, `evaluate` is what you will implement to determine if the assertion is valid or not. In regards to `equals`, we only care about the actual value (what was returned by the assertion block the user wrote) and what is expected.

`pass` and `fail` are helpers which return a tuple ... to be truthful, you can return whatever you want so long as your reporter understands it. the current format is `[:status, 'message']` where status is one of `:pass`, `:fail`, and `:error`. go nuts

#### Message Strings

"What's that interesting looking message string `expected_message(expected).not(actual)`?", you ask. Well, this a wondrous bundle of joy is all I can say. I got tired of writing strings with interpolated other strings and being all verbose; so I devised a way to let me mostly use english to construct sentences that also take variable values. Let's take a for instance; the message string you so wisely pointed out above would produce the following should the values of `expected` and `actual` be "goobers" and "nerds" respectively:

    "expected 'goobers', not 'nerds'"

And that other string, `new_message.is_equal_to(expected)` would produce:

    "is equal to 'goobers'"

Why? ...

### Context Middleware

By now you're probably asking yourself, "How could Riot get any better?"

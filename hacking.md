---
title: Hacking with Riot
description: Thing developers should know about extending Riot for their projects or libraries
keywords: ruby, testing, framework, riot, hacking
layout: default
---

## Hacking Riot

You are the Hack King. You want to succeed. When I say that, I mean it in all sincerity about you. If you didn't want to succeed, you wouldn't be looking at Riot. Ohhh! I said it.

As a co-worker once said to me, "You Ruby developers always come out with both fists punching."

Want to know something I don't like? Yes, you do. I don't like being annoyed by my test framework when I go to extend it. Testing frameworks should not be closed systems; and while Ruby makes it easy to keep code open, code can still be closed from a conceptual standpoint.

What does that mean for you? It means Riot wants to be open. It wants you to make it better with your own little do-dads, knick-knacks, code cubbies, and under-the-hood rock'em robots. Before you can do that, there are probably a few things you should know about how Riot works.

### Let's Start at the Beginning

When you define a context in your test code, Riot will create a `Riot::Context` object, tell it what you wanted the description to be, and push it onto the queue of contexts it knows about. This is boring so far, I know. When you define a sub-context (a context within a context), Riot does the same as before except that it tells this new context who its parent context is. The context tree is essentially flattened out in Riot's "mind" at this point. Riot just has one big list, though I did play around with the notion of only knowing top-level contexts. This way makes for some better abstractions of responsibility. As a Context, this bit about knowing the parent means a sub-context can "inherit" setups, teardowns, hookups, and helpers.

When a Context is added to the list of runnable Contexts, its innards are also evaluated in order to prepare/generate the actual setups, teardowns, hookups, helpers, and assertions. These are managed by the containing Context only.

When all of the Contexts have been evaluated - which happens at run-time as the classpath is getting loaded in - Riot will run through the list of Contexts in the order in which they were defined. When an assertion is executed, its result is immediately reported. Something special about Riot and assertions is that Riot creates a unique Situation for each Context. The job of the Situation is to be an evaluation instance for that context; or a data "jail" for the life of the Context. Things like `topic` or instance variables exist only while the Situation lasts. Anything that happens within a helper, setup, assertion, etc. are all evaluated against the Situation. This should mean that Contexts don't inadvertently use/collide-with each others' data. The Situation is then thrown away when the Context is finished.

### Writing Your Own Assertion Macros

This is easy ...

### Context Middleware

By now you're probably asking yourself, "How could Riot get any better?"

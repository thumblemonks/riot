---
title: Riot loot
description: Recipes for common situations encountered when testing with Riot
keywords: ruby, testing, framework, riot, loot, recipes, cookbook
layout: section
---

## The Loot

I wanted to call this section "Booty"; you might call it "Recipes" or "Cookbook", but I don't. Anyways, "loot" goes with the theme of rioting and since Ruby is the Vegas of languages[^huh] we need to stay themed.

### Adding context helper methods

If you find yourself writing similar assertions or even contexts within your application, feel free to include some new methods into `Riot::Context` that clean that duplication up. Yes, yes, simple example time. First you start with the redundant stuff:

{% highlight ruby %}
context "Messages controller:" do
  hookup do # authenticate
    session(:user, {:email => "john@doe.com", :name => "John Doe"}) # assumes we're using rack-test
  end

  context "retrieving list for logged in user"
    setup { get("/user/messages") }
    # ...
  end # retrieving list for logged in user
  
end # Messages controller

context "Followers controller:" do
  hookup do # authenticate
    session(:user, {:email => "jane@doe.com", :name => "John Doe"})
  end

  context "retrieving list for logged in user"
    setup { get("/user/followers") }
    # ...
  end # retrieving list for logged in user
  
end # Followers controller
{% endhighlight %}

It'd be nice if we could just have an `authenticate` method to call in that hookup spot. Of course, we could write a helper to do some of it for us, but we want something more elegant than even that. This would be better:

{% highlight ruby %}
context "Messages controller:" do
  authenticate("john@doe.com")

  context "retrieving list for logged in user"
    setup { get("/user/messages") }
    # ...
  end # retrieving list for logged in user
  
end # Messages controller

context "Followers controller:" do
  authenticate("jane@doe.com")

  context "retrieving list for logged in user"
    setup { get("/user/followers") }
    # ...
  end # retrieving list for logged in user
  
end # Followers controller
{% endhighlight %}

Yep, better. Cleaner and very concise. Now, to make this happen you need to define the following in your `teststrap.rb` or some other library that's loaded in at runtime:

{% highlight ruby %}
module SweetApp
  module RiotContext
    def authenticate(email)
      hookup do
        session(:user, {:email => email, :name => "John Doe"})
      end
    end
  end # RiotContext
end # SweetApp

Riot::Context.instance_eval { include SweetApp::RiotContext }
{% endhighlight %}


### Singleton-ish factory helpers

If you're like me, you like using helpers for [all the reasons I've mentioned before](./index.html#helpers). However, there are times when you want to have a helper that generates a new instance of something, but only one for the scope of the context.

{% highlight ruby %}
context "Making some time" do
  helper(:right_now) { @right_now ||= Time.new }
  
  helper(:hours_from_now) do |hours|
    (right_now + (hours * 3600)).strftime("%Y%m%d-%H%M")
  end

  # ...
end # Making some time
{% endhighlight %}

I see you pointing your finger and screaming *"Instance variable ... instance variable ... ya ya ya!"* Whatever, sue me. I get to say `right_now` everywhere else.

<!-- footnotes -->

[^huh]: I have no idea what "the Vegas of languages" means, but it sounds awesome anyways.

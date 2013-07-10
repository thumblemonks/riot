module Riot

  # Context middlewares are chainable, context preparers. This to say that a middleware knows about a single
  # neighbor and that it can prepare context before the context is "run". As a for instance, suppose you
  # wanted the following to be possible.
  #
  #   context Person do
  #     denies(:valid?)
  #   end # Person
  #
  # Without writing a middleware, the topic in this would actually be nil, but what the context is saying is
  # that there should be something in the topic that responds to +:valid?+; an instance of +Person+ in this
  # case. We can do this with middleware like so:
  #
  #   class Modelware < Riot::ContextMiddleware
  #     register
  #
  #     def call(context)
  #       if context.description.kind_of?(Model)
  #         context.setup { context.description.new }
  #       end
  #       middleware.call(context)
  #     end
  #   end # Modelware
  #
  # That's good stuff. If you're familiar at all with the nature of Rack middleware - how to implement it,
  # how it's executed, etc. - you'll be familiar with Context middleware as the principles are similar:
  #
  # 1. Define a class that extends {Riot::ContextMiddleware}
  # 2. Call +register+
  # 3. Implement a +call+ method that accepts the Context that is about to be executed
  # 4. Do stuff, but make sure to pass the call along with +middleware.call(context)+
  #
  # Steps 1, 2, and 3 should be pretty straight-forward. Currently, +context+ is the only argument to +call+.
  # When your middleware is initialized it is given the next registered middleware in the chain (which is
  # where the `middleware` method gets its value from).
  #
  # So, "Do stuff" from step 4 is the where we start breaking things down. What can you actually do? Well,
  # you can do anything to the context that you could do if you were writing a Riot test; and I do mean
  # anything.
  #
  # * Add setup blocks (as many as you like)
  # * Add teardown blocks (as many as you like)
  # * Add hookup blocks (as many as you like)
  # * Add helpers (as many as you like)
  # * Add assertions
  #
  # The context in question will not run before all middleware have been applied to the context; this is
  # different behavior than that of Rack middleware. {Riot::ContextMiddleware} is only about preparing a
  # context, not about executing it. Thus, where in your method you actually pass the call off to the next
  # middleware in the chain has impact on how the context is set up. Basically, whatever you do before
  # calling `middleware.call(context)` is done before any other middleware gets setup and before the innards
  # of the context itself are applied. Whatever you do after that call is done after all that, but still
  # before the actual setups, hookups, assertions, and teardowns are run.
  #
  # Do not expect the same instance of middleware to exist from one {Riot::Context} instance to the next. It
  # is highly likely that each {Riot::Context} will instantiate their own middleware instances.
  class ContextMiddleware
    # Registers the current middleware class with Riot so that it may be included in the set of middlewares
    # Riot will poke before executing a Context.
    #
    #   class MyContextMiddleware < Riot::ContextMiddleware
    #     register
    #     def call(context)
    #       context.setup { ... }
    #       middleware.call(context) # this can go anywhere
    #       context.hookup { ... }
    #     end
    #   end
    def self.register
      Context.middlewares << self
    end

    # Theoretically, the next middleware in the stack
    attr_reader :middleware

    # Create a new middleware instance and give it the next middleware in the chain.
    #
    # @param [Riot::ContextMiddleware] middleware the next middleware instance in the chain
    def initialize(middleware)
      @middleware = middleware
    end

    # The magic happens here. Because you have access to the Context, you can add your own setups, hookups,
    # etc. +call+ will be called before any tests are run, but after the Context is configured. Though
    # something will likely be returned, do not put any faith in what that will be.
    #
    # @param [Riot::Context] context the Context instance that will be prepared by registered middleware
    def call(context)
      raise "You should implement call yourself"
    end
  end # ContextMiddleware

  # Special middleware used by Context directly. It will always be the last in the chain and is the actual
  # place where the user's runtime context is processed.
  class AllImportantMiddleware < ContextMiddleware
    def initialize(&context_definition)
      @context_definition = context_definition
    end

    # (see Riot::ContextMiddleware#call)
    def call(context) context.instance_eval(&@context_definition); end
  end # AllImportantMiddleware

end # Riot

module Riot

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
    def self.register; Context.middlewares << self; end

    attr_reader :middleware # Theoretically, the next middleware in the stack

    def initialize(middleware)
      @middleware = middleware
    end

    # The meat. Because you have access to the Context, you can add your own setups,
    # hookups, etc. +call+ will be called before any tests are run, but after the Context is configured.
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

    def call(context) context.instance_eval(&@context_definition); end
  end # AllImportantMiddleware

end # Riot

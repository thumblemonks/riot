module Riot
  module ContextOptions

    # Set options for the specific context. These options will generally be used for context middleware.
    # Riot::Context does not currently look at any options.
    #
    #   context "Foo" do
    #     set :transactional, true
    #   end
    #
    # @param [Object] key the key used to look up the option value later
    # @param [Object] value the option value to store
    def set(key, value)
      option_set[key] = value
    end

    # Returns the value of a set option. The key must match exactly, symbols and strings are not
    # interchangeable.
    #
    # @param [Object] key the key used to look up the option value
    # @return [Object]
    def option(key)
      option_set[key]
    end

    # Returns the hash of defined options.
    #
    # @return [Hash]
    def option_set
      @options ||= {}
    end

  end # ContextOptions
end # Riot

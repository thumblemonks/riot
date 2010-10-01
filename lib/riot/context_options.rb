module Riot
  module ContextOptions

    # Set options for the specific context. These options will generally be used for context middleware.
    # Riot::Context does not currently look at any options.
    #
    #   context "Foo" do
    #     set :transactional, true
    #   end
    def set(key, value) options[key] = value; end

    # Returns the value of a set option. The key must match exactly, symbols and strings are not
    # interchangeable.
    #
    # @return [Object]
    def option(key) options[key]; end

    # Returns the has of defined options.
    #
    # @return [Hash]
    def options; @options ||= {}; end

  end # ContextOptions
end # Riot

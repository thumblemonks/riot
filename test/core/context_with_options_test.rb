require 'teststrap'

context "Context with options" do
  setup do
    Riot::Context.new("Foo") do
      set :foo, "bar"
      set "bar", 2
    end
  end

  asserts_topic.responds_to(:option)

  asserts("option :foo") { topic.option(:foo) }.equals("bar")
  asserts("option \"foo\"") { topic.option("foo") }.nil
  asserts("option \"bar\"") { topic.option("bar") }.equals(2)
end # Context with options

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

  context "and with a nested context" do
    setup do
      Riot::Context.new("Foo", topic) do
        set :goo, "car"
        set "car", 3
      end
    end

    asserts_topic.responds_to(:option)

    asserts("option :foo") { topic.option(:foo) }.equals("bar")
    asserts("option \"bar\"") { topic.option("bar") }.equals(2)

    asserts("option :goo") { topic.option(:goo) }.equals("car")
    asserts("option \"car\"") { topic.option("car") }.equals(3)
  end # and with a nested context
end # Context with options

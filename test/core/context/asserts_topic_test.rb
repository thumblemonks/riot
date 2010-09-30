require 'teststrap'

context "The asserts_topic shortcut" do
  setup do
    Riot::Context.new("foo") {}.asserts_topic
  end

  should("return an Assertion") { topic }.kind_of(Riot::Assertion)

  should("return the actual topic as the result of evaling the assertion") do
    (situation = Riot::Situation.new).instance_variable_set(:@_topic, "bar")
    topic.equals("bar").run(situation)
  end.equals([:pass, %Q{is equal to "bar"}])

  asserts(:to_s).equals("asserts that it")

  context "with an explicit description" do
    setup { Riot::Context.new("foo") {}.asserts_topic("get some") }
    asserts(:to_s).equals("asserts get some")
  end
end # The asserts_topic shortcut

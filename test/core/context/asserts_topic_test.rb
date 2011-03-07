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

context "The denies_topic shortcut" do
  setup do
    Riot::Context.new("foo") {}.denies_topic
  end

  should("return an Assertion") { topic }.kind_of(Riot::Assertion)

  should("return the actual topic as the result of evaling the assertion") do
    (situation = Riot::Situation.new).instance_variable_set(:@_topic, "bar")
    topic.equals("not bar").run(situation)
  end.equals([:pass, %Q{is equal to "not bar" when it is "bar"}])

  asserts(:to_s).equals("denies that it")

  context "with an explicit description" do
    setup { Riot::Context.new("foo") {}.denies_topic("get some") }
    asserts(:to_s).equals("denies get some")
  end
end # The denies_topic shortcut

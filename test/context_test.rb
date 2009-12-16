require 'teststrap'

context "Reporting a context" do
  setup do
    a_context = Riot::Context.new("foobar") do
      asserts("passing") { true }
      asserts("failing") { false }
      asserts("erroring") { raise Exception }
    end
    a_context.run(MockReporter.new)
  end

  asserts("one passed test") { topic.passes == 1 }
  asserts("one failed test") { topic.failures == 1 }
  asserts("one errored test") { topic.errors == 1 }
end # Reporting a context

context "Defining a context with multiple setups" do
  setup do
    @a_context = Riot::Context.new("foobar") do
      setup { "foo" }
      setup { topic + "bar" }
      asserts("blah") { topic == "foobar" }
    end
    @a_context.run(MockReporter.new)
  end
  asserts("has setups") { @a_context.setups.count }.equals(2)
  asserts("all tests pass") { topic.passes == 1 }
end # Defining a context with multiple setups

context "Nesting a context" do
  setup do
    a_context = Riot::Context.new("foobar") do
      asserts("passing") { true }
      context "bazboo" do
        asserts("passing") { true }
        asserts("failing") { false }
        asserts("erroring") { raise Exception }
      end
    end
    a_context.run(MockReporter.new)
  end

  asserts("one passed test") { topic.passes == 2 }
  asserts("one failed test") { topic.failures == 1 }
  asserts("one errored test") { topic.errors == 1 }

  context "with setups" do
    setup do
      a_context = Riot::Context.new("foobar") do
        setup { "foo" }
        context "bazboo" do
          setup { topic + "bar" }
          asserts("passing") { topic == "foobar" }
        end
      end
      a_context.run(MockReporter.new)
    end

    asserts("parent setups are called") { topic.passes == 1 }
  end # with setups
end # Nesting a context

context "Using should" do
  setup do
    a_context = Riot::Context.new("foobar") do
      should("pass") { true }
      should("fail") { false }
      should("error") { raise Exception }
    end
    a_context.run(MockReporter.new)
  end

  asserts("one passed test") { topic.passes == 1 }
  asserts("one failed test") { topic.failures == 1 }
  asserts("one errored test") { topic.errors == 1 }
end # Using should

context "The asserts_topic shortcut" do
  setup do
    Riot::Context.new("foo") {}.asserts_topic
  end

  should("return an Assertion") { topic }.kind_of(Riot::Assertion)

  should("return the actual topic as the result of evaling the assertion") do
    (situation = Riot::Situation.new).topic = "bar"
    topic.equals("bar").run(situation)
  end.equals([:pass])
end # The asserts_topic shortcut

context "Setting assertion extensions" do
  fake_mod_one, fake_mod_two = Module.new, Module.new

  setup do
    Riot::Context.new("foo") do
      extend_assertions fake_mod_one, fake_mod_two
    end.asserts_topic
  end

  should("still return an Assertion") { topic }.kind_of(Riot::Assertion)

  should("have included the fake_mod_one assertion extension module") do
    topic.class.included_modules
  end.includes(fake_mod_one)

  should("have included the fake_mod_two assertion extension module") do
    topic.class.included_modules
  end.includes(fake_mod_two)

  context "involving subcontexts without the subcontext extending assertions" do
    assertion_one = assertion_two = nil

    setup do 
      Riot::Context.new "bleh" do
        extend_assertions Module.new
        assertion_one = asserts_topic
        context("foo") { assertion_two = asserts_topic } 
      end
    end

    asserts("assertion one") { assertion_one }.exists
    asserts("assertion two") { assertion_two }.exists

    asserts("assertions are of the same assertion class") do
      assertion_one.class.object_id
    end.equals {assertion_two.class.object_id}
  end # involving subcontexts without the subcontext extending assertions

  context "involving subcontexts with the subcontext extending assertions" do
    assertion_one = assertion_two = nil
    
    setup do
      Riot::Context.new "bah" do
        extend_assertions Module.new
        assertion_one = asserts_topic
        context("meh") do
          extend_assertions Module.new
          assertion_two = asserts_topic
        end
      end
    end

    asserts("assertion one") { assertion_one }.exists
    asserts("assertion two") { assertion_two }.exists

    should "create separate instances of the assertion class in subcontexts" do
      assertion_one.class.object_id != assertion_two.class.object_id
    end

  end # involving subcontexts with the subcontext extending assertions
end   # Setting assertion extensions

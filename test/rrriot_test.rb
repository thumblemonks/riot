require 'teststrap'
require 'riot/rr'

context "Riot with RR support" do
  asserts("RR methods are available to an RR::Situation") do
    Riot::RR::Situation.ancestors
  end.includes(::RR::Adapters::RRMethods)

  asserts("assertion passes when RR is satisfied") do
    situation = Riot::RR::Situation.new
    Riot::RR::Assertion.new("Satisfied") { true }.run(situation)
  end.equals([:pass, ""])

  asserts("assertion fails when RR is displeased") do
    situation = Riot::RR::Situation.new
    Riot::RR::Assertion.new("Displeased") { mock!.hello }.run(situation)
  end.equals([:fail, "hello() Called 0 times. Expected 1 times."])

  asserts("RR verification is reset between assertion runs") do
    situation = Riot::RR::Situation.new
    Riot::RR::Assertion.new("Displeased") { mock!.hello }.run(situation)
    Riot::RR::Assertion.new("Displeased differently") { mock!.goodbye }.run(situation)
  end.equals([:fail, "goodbye() Called 0 times. Expected 1 times."])

  context "with RR doubles defined in setup" do
    setup do
      situation = Riot::RR::Situation.new
      situation.setup { mock!.hello }
      situation
    end
    
    asserts("an assertion") do
      Riot::RR::Assertion.new("test") { "foo" }.run(topic)
    end.equals([:fail, "hello() Called 0 times. Expected 1 times."])

    asserts("another assertion") do
      Riot::RR::Assertion.new("test") { "bar" }.run(topic)
    end.equals([:fail, "hello() Called 0 times. Expected 1 times."])
  end # with RR doubles defined in setup

  context "when using the RR context" do
    setup do
      fake_context = Class.new(Riot::Context) { }
      Riot::RR.enable(fake_context)
      fake_context.new("foo") {}
    end

    asserts("new assertions") do
      topic.asserts("nothing really") { true }
    end.kind_of(Riot::RR::Assertion)
    
    asserts("situation class") { topic.__send__(:situation_class) }.equals(Riot::RR::Situation)
  end # when using the RR context

end # Riot with RR support

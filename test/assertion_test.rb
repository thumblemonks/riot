require 'teststrap'

context "basic assertion" do
  setup { Riot::Situation.new }

  should "have a description" do
    Riot::Assertion.new("i will pass", topic).to_s
  end.equals("i will pass")

  asserts "pass? is true when assertion passed" do
    Riot::Assertion.new("i will pass", topic) { true }.passed?
  end

  asserts "failure? is true when assertion does not pass" do
    Riot::Assertion.new("i will pass", topic) { false }.failed?
  end

  asserts "error? is true when an unexpected Exception is raised" do
    Riot::Assertion.new("error", topic) { raise Exception, "blah" }.errored?
  end

  context "that fails while executing a test" do
    setup do
      fake_situation = Riot::Situation.new
      Riot::Assertion.new("error", fake_situation) { fail("I'm a bum") }
    end

    should("be considered a failing assertion") { topic.failed? }
    should("use failed message in description") { topic.result.message }.matches(/I'm a bum/)
  end # that fails while executing test
end # basic assertion

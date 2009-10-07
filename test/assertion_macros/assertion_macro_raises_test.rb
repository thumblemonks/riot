require 'teststrap'

context "raises assertion:" do
  setup { Riot::Situation.new }

  should("raise an Exception") { raise Exception }.raises(Exception)

  should "pass if provided message equals expectation" do
    Riot::Assertion.new("foo", topic) { raise Exception, "I'm a nerd" }.raises(Exception, "I'm a nerd")
  end

  should "fail if provided message does not equal expectation" do
    Riot::Assertion.new("foo", topic) { raise(Exception, "I'm a nerd") }.raises(Exception, "But I'm not")
  end.kind_of(Riot::Failure)

  should "pass if provided message matches expectation" do
    Riot::Assertion.new("foo", topic) { raise(Exception, "I'm a nerd") }.raises(Exception, /nerd/)
  end

  should "fail if provided message does not match expectation" do
    Riot::Assertion.new("foo", topic) { raise(Exception, "I'm a nerd") }.raises(Exception, /foo/)
  end.kind_of(Riot::Failure)

  should "pass if provided message as array equals expectation" do
    Riot::Assertion.new("foo", topic) { raise(Exception, ["foo", "bar"]) }.raises(Exception, "foobar")
  end

  should "pass if provided message as array matches expectation" do
    Riot::Assertion.new("foo", topic) { raise(Exception, ["foo", "bar"]) }.raises(Exception, /oba/)
  end
end # raises assertion
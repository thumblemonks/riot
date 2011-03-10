require 'teststrap'

context "a negative assertion made with arguments" do
  setup do
    Riot::Context.new("foo") {}.denies(:[], 0)
  end

  should("pass its argument to send, with the first argument as method name") do
    (situation = Riot::Situation.new).instance_variable_set(:@_topic, [1, 2])
    topic.equals(1).run(situation).first
  end.equals(:fail)
end # assertion made with arguments

